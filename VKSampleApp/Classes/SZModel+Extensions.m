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
    NSString *rootFolder = [[SZImageCache cacheDirectory] stringByAppendingPathComponent:@"Large"];
    return [rootFolder stringByAppendingPathComponent:[self.photoURI md5]];
}

- (NSString*)thumbnailImagePath {
    NSString *rootFolder = [[SZImageCache cacheDirectory] stringByAppendingPathComponent:@"Small"];
    return [rootFolder stringByAppendingPathComponent:[self.thumbnailURI md5]];
}

@end

@implementation SZUser (Extensions)

-(NSString *)avatarImagePath {
    NSString *rootFolder = [[SZImageCache cacheDirectory] stringByAppendingPathComponent:@"Avatars"];
    return [rootFolder stringByAppendingPathComponent:[self.avatarURI md5]];
}

@end
