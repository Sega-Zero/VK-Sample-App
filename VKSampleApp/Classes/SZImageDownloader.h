//
//  SZImageDownloader.h
//  VKSampleApp
//
//  Created by Сергей Галездинов on 28.06.15.
//  Copyright (c) 2015 Сергей Галездинов. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SZImageDownloader : NSObject

/**
 Designated initializer. 
 @param
 queueLimit number of simultaneous image downloads allowed
 */
- (instancetype)initWithQueueLimit:(NSUInteger)queueLimit;

- (void)downloadImageWithURL:(NSString*)url toFilePath:(NSString*)filePath completionHandler:(void(^)(NSError *error, NSString *url))completionHandler;

/**
 Cancel all images loading
 */
- (void)cancel;

@end
