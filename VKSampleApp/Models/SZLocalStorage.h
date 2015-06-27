//
//  SZLocalStorage.h
//  VKSampleApp
//
//  Created by Сергей Галездинов on 24.06.15.
//  Copyright (c) 2015 Сергей Галездинов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SZModel.h"

/**
 Wrapper over Core Data model. The general purpose of it is to store newsfeed, users and comments
 */
@interface SZLocalStorage : NSObject

/**
 NSFetchedResultsController to be used in newsfeed UI
 @param
 delegate delegate that will receive changes
 */
- (NSFetchedResultsController *)newsFeedFetchedResultsController:(id<NSFetchedResultsControllerDelegate>)delegate;

/**
 Clean up Magical Record Stack
 */
- (void)cleanUpStack;

/**
 Clear all database entries
 */
- (void)removeAllRecords;

- (BOOL)isEmpty;

/**
 Appends an array of vk posts into database
 @param
 postsMap dictionary containing map {userId = post}
 @param
 users array of vk users dictionaries
 @param
 completionHandler block to be called on completion
 */
- (void)addPosts:(NSDictionary*)postsMap fromUsers:(NSArray*)users completionHandler:(dispatch_block_t)completionHandler;

@end
