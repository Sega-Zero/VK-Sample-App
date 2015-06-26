//
//  SZVKTransformer.h
//  VKSampleApp
//
//  Created by Сергей Галездинов on 26.06.15.
//  Copyright (c) 2015 Сергей Галездинов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/**
 Base class for transformers from vk objects to core data object model
 */
@interface SZVKTransformer : NSObject

- (instancetype)initWithObject:(NSDictionary*)object;

- (NSString*)objectID;
- (void)fillEntity:(NSManagedObject*)entity;

@end

/**
 Transformer for user entities
 */
@interface SZVKUserDataTransformer : SZVKTransformer

@end

@interface SZVKPhotoDataTransformer : SZVKTransformer

@end

/**
 Transformer for post entities
 */
@interface SZVKPostDataTransformer : SZVKTransformer

/**
 Returns transformers for all photo attachments
 @note
 result array contains instances of SZVKPhotoDataTransformer
 */
- (NSArray*)photoTransformers;
@end
