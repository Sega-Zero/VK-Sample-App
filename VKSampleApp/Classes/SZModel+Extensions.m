//
//  SZModel+Extensions.m
//  VKSampleApp
//
//  Created by Сергей Галездинов on 28.06.15.
//  Copyright (c) 2015 Сергей Галездинов. All rights reserved.
//

#import "SZModel+Extensions.h"
#import "SZImageCache.h"
#import "NSString+Utils.h"

@implementation SZPhoto (Extensions)

- (NSString*)fullImagePath {
    //assume last path component is unique
    NSString *rootFolder = [[SZImageCache cacheDirectory] stringByAppendingPathComponent:@"Large"];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![[NSFileManager defaultManager] fileExistsAtPath:rootFolder]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:rootFolder withIntermediateDirectories:YES attributes:nil error:nil];
        }
    });
    return [rootFolder stringByAppendingPathComponent:[self.photoURI md5]];
}

- (NSString*)thumbnailImagePath {
    NSString *rootFolder = [[SZImageCache cacheDirectory] stringByAppendingPathComponent:@"Small"];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![[NSFileManager defaultManager] fileExistsAtPath:rootFolder]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:rootFolder withIntermediateDirectories:YES attributes:nil error:nil];
        }
    });
    return [rootFolder stringByAppendingPathComponent:[self.thumbnailURI md5]];
}

@end

@implementation SZUser (Extensions)

-(NSString *)avatarImagePath {
    NSString *rootFolder = [[SZImageCache cacheDirectory] stringByAppendingPathComponent:@"Avatars"];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![[NSFileManager defaultManager] fileExistsAtPath:rootFolder]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:rootFolder withIntermediateDirectories:YES attributes:nil error:nil];
        }
    });
    return [rootFolder stringByAppendingPathComponent:[self.avatarURI md5]];
}

@end
