//
//  SZImageCache.m
//  VKSampleApp
//
//  Created by Сергей Галездинов on 25.06.15.
//  Copyright (c) 2015 Сергей Галездинов. All rights reserved.
//

#import "SZImageCache.h"

@implementation SZImageCache

#pragma mark init 

- (instancetype)initWithSize:(CGSize)imageSize {
    self = [super init];
    if (self) {
        //TODO: init cache
    }
    return self;
}

#pragma mark public methods

- (void)loadImageWithPath:(NSString*)imagePath completionHandler:(SZImageLoadBlock)completionHandler {
//TODO: implement
}

- (void)clearCache {
//TODO: implement
}

+ (NSString*) cacheDirectory {
    static NSString *cachePath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
        cachePath = [[cachePath stringByAppendingString:[NSBundle mainBundle].bundleIdentifier] stringByAppendingString:@"Images"];

        NSFileManager* fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:cachePath]) {
            [fm createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    });

    return cachePath;
}

@end
