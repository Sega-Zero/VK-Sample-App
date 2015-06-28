//
//  SZVKImageManager.h
//  VKSampleApp
//
//  Created by Сергей Галездинов on 25.06.15.
//  Copyright (c) 2015 Сергей Галездинов. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SZModel.h"

/**
 The purpose of this class is to manage loading an images from cache or http
 */
@interface SZVKImageManager : NSObject

- (void)setImageFromUser:(SZUser*)user to:(UIImageView*)imageView;
- (void)setThumbnailImageFromPhoto:(SZPhoto*)photo to:(UIImageView*)imageView;
- (void)loadFullImageFromPhoto:(SZPhoto*)photo completionHandler:(void(^)(UIImage *image))completionHandler;

/**
 Stop all current downloads, clear internal cache
 */
- (void)cleanup;

@end
