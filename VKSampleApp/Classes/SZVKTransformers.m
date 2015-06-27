//
//  SZVKTransformer.m
//  VKSampleApp
//
//  Created by Сергей Галездинов on 26.06.15.
//  Copyright (c) 2015 Сергей Галездинов. All rights reserved.
//

#import "SZVKTransformers.h"
#import "SZModel.h"

@interface SZVKTransformer()

@property (readonly,nonatomic) NSDictionary *object;

@end

@implementation SZVKTransformer

- (instancetype)initWithObject:(NSDictionary*)object {
    self = [super init];
    if (self) {
        _object = object;
    }
    return self;
}

- (NSString*)objectID {
    return nil;
}

- (void)fillEntity:(NSManagedObject*)entity {

}

@end

@implementation SZVKUserDataTransformer

-(NSString *)objectID {
    return [NSString stringWithFormat:@"%@",self.object[@"uid"]];
}

-(void)fillEntity:(SZUser *)entity {
    entity.avatarURI = self.object[@"photo"];
    entity.id = [self objectID];

    NSString *firstName = self.object[@"first_name"];
    NSString *lastName = self.object[@"last_name"];
    NSString *name = [[NSString stringWithFormat:@"%@ %@", firstName, lastName] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    entity.name = name.length > 0 ? name : self.object[@"screen_name"];
}

@end

@implementation SZVKPhotoDataTransformer

-(void)fillEntity:(SZPhoto *)entity {
    entity.width = self.object[@"width"];
    entity.height = self.object[@"height"];
    entity.thumbnailURI = self.object[@"src"];

    if (self.object[@"src_xxxbig"] || self.object[@"photo_2560"]) {

        entity.photoURI = self.object[@"photo_2560"] ?: self.object[@"src_xxxbig"];

    } else if (self.object[@"src_xxbig"] || self.object[@"photo_1280"]) {

        entity.photoURI = self.object[@"photo_1280"] ?: self.object[@"src_xxbig"];

    } else if (self.object[@"src_xbig"] || self.object[@"photo_807"]) {

        entity.photoURI = self.object[@"photo_807"] ?: self.object[@"src_xbig"];

    } else if (self.object[@"src_big"] || self.object[@"photo_604"]) {
        
        entity.photoURI = self.object[@"photo_604"] ?: self.object[@"src_big"];

    }
}

@end

@implementation SZVKPostDataTransformer

-(NSString *)objectID {
    return self.object[@"post_id"] ? [NSString stringWithFormat:@"%@",self.object[@"post_id"]] : nil;
}

-(void)fillEntity:(SZPost *)entity {
    entity.date = [NSDate dateWithTimeIntervalSince1970:[self.object[@"date"] doubleValue]];
    entity.id = [self objectID];
    entity.likesCount = self.object[@"likes"][@"count"];
    entity.repostCount = self.object[@"reposts"][@"count"];

    NSString *text = self.object[@"text"];
    if (text.length == 0 && self.object[@"geo"]) {
        text = self.object[@"geo"][@"title"];
        if (text.length == 0) {
            text = self.object[@"geo"][@"place"][@"title"];
        }
    }
    if (text.length == 0 && self.object[@"attachment"][@"link"]) {
        text = self.object[@"attachment"][@"link"][@"url"];
    }
    if (text.length == 0 && self.object[@"attachment"][@"audio"]) {
        text = NSLocalizedString(@"audio", "'audio' title for post content");
    }
    entity.text = text;
}

- (NSArray*)photoTransformers {
    NSMutableArray *photos = [NSMutableArray new];
    NSArray *attachments = self.object[@"attachments"];
    if (attachments.count == 0 && self.object[@"attachment"]) {
        attachments = [NSArray arrayWithObject:self.object[@"attachment"]];
    }
    if (attachments.count == 0) {
        return @[];
    }
    for (NSDictionary *attachment in attachments) {
        if ([attachment[@"type"] isEqualToString:@"photo"]) {
            SZVKPhotoDataTransformer *transformer = [[SZVKPhotoDataTransformer alloc] initWithObject:attachment[@"photo"]];
            [photos addObject:transformer];
        }
    }
    
    return photos;
}

@end