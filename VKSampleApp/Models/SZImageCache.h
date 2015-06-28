//
//  SZImageCache.h
//  VKSampleApp
//
//  Created by Сергей Галездинов on 25.06.15.
//  Copyright (c) 2015 Сергей Галездинов. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SZImageLoadBlock)(UIImage *image, NSString *loadPath);

/**
 Class that handles all local images caching. Built on top of FastImageCache.
 */
@interface SZImageCache : NSObject

/**
 Designated initializer.
 @param
 imageSize image size that cache blocks depends on
 */
- (instancetype)initWithSize:(CGSize)imageSize maxCacheCount:(NSUInteger)maxCacheCount;

/**
 Asynchronously loads image from cache (from fast cache or file).
 @param
 imagePath file path of image
 @param
 completionHandler block to be called on successful cache load
 */
- (void)loadImageWithPath:(NSString*)imagePath completionHandler:(SZImageLoadBlock)completionHandler;

/**
 Remove local cache 
 */
- (void)clearCache;

/**
 Directory for image files
 */
+ (NSString*) cacheDirectory;

@end
