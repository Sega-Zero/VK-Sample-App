//
//  SZLocalStorage.m
//  VKSampleApp
//
//  Created by Сергей Галездинов on 24.06.15.
//  Copyright (c) 2015 Сергей Галездинов. All rights reserved.
//

#import "SZLocalStorage.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import <MagicalRecord/MagicalRecord.h>
#import "SZVKTransformers.h"

@implementation SZLocalStorage

#pragma mark init 

- (instancetype)init {
    self = [super init];
    if (self) {
        [MagicalRecord setupAutoMigratingCoreDataStack];
    }
    return self;
}

- (void)dealloc {
    [self cleanUpStack];
}

#pragma mark public methods

- (NSFetchedResultsController *)newsFeedFetchedResultsController:(id<NSFetchedResultsControllerDelegate>)delegate {

    NSFetchedResultsController *result = [SZPost MR_fetchAllSortedBy:@"date" ascending:NO withPredicate:nil groupBy:nil delegate:delegate];

    NSError *error = nil;
    if (![result performFetch:&error] || error) {
        DDLogError(@"[storage] couldn't perform fetch with error %@", error);
    };

    return result;
}

- (void)cleanUpStack {
    [MagicalRecord cleanUp];
}

- (void)removeAllRecords {
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        [SZUser MR_truncateAllInContext:localContext];
        [SZPost MR_truncateAllInContext:localContext];
    }];
}

- (BOOL)isEmpty {
    return [[SZPost MR_numberOfEntities] unsignedIntegerValue] == 0 && [[SZUser MR_numberOfEntities] unsignedIntegerValue] == 0;
}

- (void)addPosts:(NSDictionary*)postsMap fromUsers:(NSArray*)users completionHandler:(dispatch_block_t)completionHandler {
    //all the import will be in separate saving queue
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        for (NSDictionary *user in users) {
            SZVKTransformer *transformer = [[SZVKUserDataTransformer alloc] initWithObject:user];
            if ([transformer objectID].length == 0) {
                break;
            }

            SZUser *existingUser = [SZUser MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"id = %@",transformer.objectID] inContext:localContext];

            if (!existingUser) {
                existingUser = [SZUser MR_createEntityInContext:localContext];
            }

            //user's avatar may change, so we fill user entity always
            [transformer fillEntity:existingUser];

            //TODO: check avatar has been changed?

            //retrieve all posts for this user
            NSArray *posts = postsMap[transformer.objectID];
            for (NSDictionary *post in posts) {
                SZVKPostDataTransformer *postTransformer = [[SZVKPostDataTransformer alloc] initWithObject:post];
                //separate photo posts will not have an id, so we should skip it, since we cannot add it to database
                //TODO: maybe we should generate id from the url?
                if ([postTransformer objectID].length == 0) {
                    break;
                }

                SZPost *existingPost = [SZPost MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"id = %@",postTransformer.objectID] inContext:localContext];

                if (!existingPost) {
                    existingPost = [SZPost MR_createEntityInContext:localContext];
                }
                existingPost.author = existingUser;

                [postTransformer fillEntity:existingPost];

                NSMutableOrderedSet *newPhotos = [NSMutableOrderedSet new];
                for (SZVKPhotoDataTransformer *photoTransformer in [postTransformer photoTransformers]) {
                    SZPhoto *photo = [SZPhoto MR_createEntityInContext:localContext];
                    [photoTransformer fillEntity:photo];
                    [newPhotos addObject:photo];
                }
                if (newPhotos.count > 0) {
                    [existingPost removePhotos:[existingPost photos]];
                    [existingPost addPhotos:newPhotos];
                }
            }
        }
        
    } completion:^(BOOL contextDidSave, NSError *error) {
        if (error) {
            DDLogError(@"[storage] context save error: %@/%@", error, users);
        }

        if (completionHandler) {
            dispatch_sync(dispatch_get_main_queue(), completionHandler);
        };
    }];
}

@end
