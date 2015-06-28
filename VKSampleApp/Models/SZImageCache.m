//
//  SZImageCache.m
//  VKSampleApp
//
//  Created by Сергей Галездинов on 25.06.15.
//  Copyright (c) 2015 Сергей Галездинов. All rights reserved.
//

#import "SZImageCache.h"
#import <FastImageCache/FICImageCache.h>
#import <FastImageCache/FICUtilities.h>
#import "NSString+Utils.h"

@interface SZCacheEntity : NSObject<FICEntity>

@property (nonatomic) NSString *filePath;

+(instancetype) cacheEntryWithPath:(NSString*)filePath;

@end

@implementation SZCacheEntity
{
    NSString *_uuid;
}

+(instancetype) cacheEntryWithPath:(NSString*)filePath
{
    SZCacheEntity *result = [SZCacheEntity new];
    result.filePath = filePath;
    return result;
}

-(NSString *)UUID
{
    if (!_uuid) {
        CFUUIDBytes UUIDBytes = FICUUIDBytesFromMD5HashOfString([self.filePath md5]);
        _uuid = FICStringWithUUIDBytes(UUIDBytes);
    }
    return _uuid;
}

-(NSString *)sourceImageUUID
{
    return self.UUID;
}

-(NSURL *)sourceImageURLWithFormatName:(NSString *)formatName
{
    return [NSURL fileURLWithPath:self.filePath];
}

-(FICEntityImageDrawingBlock)drawingBlockForImage:(UIImage *)image withFormatName:(NSString *)formatName
{
    return ^(CGContextRef context, CGSize contextSize) {
        CGRect contextBounds = CGRectZero;
        contextBounds.size = contextSize;
        CGContextClearRect(context, contextBounds);

        UIGraphicsPushContext(context);
        if (image.size.height != image.size.width) {
            CGFloat maxSide = MAX(image.size.width, image.size.height);
            CGFloat mutliplier = contextSize.width / maxSide;

            CGSize aspectFitSize = CGSizeMake(image.size.width * mutliplier, image.size.height * mutliplier);
            contextBounds = CGRectMake((CGRectGetWidth(contextBounds) - aspectFitSize.width) / 2,
                                       (CGRectGetHeight(contextBounds) - aspectFitSize.height) / 2,
                                       aspectFitSize.width,
                                       aspectFitSize.height);
        }

        [image drawInRect:contextBounds];
        UIGraphicsPopContext();
    };
}

@end

@interface SZImageCache()<FICImageCacheDelegate>

@end

@implementation SZImageCache
{
    NSString *_entityFormat;
    FICImageCache *_internalCache;
}

#pragma mark init 

- (instancetype)initWithSize:(CGSize)imageSize  maxCacheCount:(NSUInteger)maxCacheCount{
    self = [super init];
    if (self) {
        _entityFormat = [NSString stringWithFormat:@"Cache%f.%f", imageSize.width, imageSize.height];
        _internalCache = [[FICImageCache alloc] initWithNameSpace:@"VKImageCache"];
        [_internalCache setDelegate:self];
        [_internalCache setFormats:@[[FICImageFormat formatWithName:_entityFormat
                                                             family:[NSBundle mainBundle].bundleIdentifier
                                                          imageSize:imageSize
                                                              style:FICImageFormatStyle32BitBGRA
                                                       maximumCount:maxCacheCount
                                                            devices:FICImageFormatDevicePhone | FICImageFormatDevicePad
                                                     protectionMode:FICImageFormatProtectionModeNone]]];
    }
    return self;
}

#pragma mark public methods

- (void)loadImageWithPath:(NSString*)imagePath completionHandler:(SZImageLoadBlock)completionHandler {
    SZCacheEntity *loadEntity = [SZCacheEntity cacheEntryWithPath:imagePath];

    __block UIImage *result = nil;
    if ([_internalCache imageExistsForEntity:loadEntity withFormatName:_entityFormat]) {
        [_internalCache retrieveImageForEntity:loadEntity withFormatName:_entityFormat completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image) {
            result = image;
        }];
    }

    if (result) {
        if (completionHandler) {
            completionHandler(result, imagePath);
        }

        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [_internalCache asynchronouslyRetrieveImageForEntity:loadEntity
                                       withFormatName:_entityFormat
                                      completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image) {
                                          if (completionHandler) {
                                              completionHandler(image, imagePath);
                                          }
                                      }];
    });
}

- (void)clearCache {
    [_internalCache reset];
}

+ (NSString*) cacheDirectory {
    static NSString *cachePath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
        cachePath = [[cachePath stringByAppendingPathComponent:[NSBundle mainBundle].bundleIdentifier] stringByAppendingPathComponent:@"Images"];

        NSFileManager* fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:cachePath]) {
            [fm createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    });

    return cachePath;
}

#pragma mark FastImageCache delegate

- (void)imageCache:(FICImageCache *)imageCache wantsSourceImageForEntity:(SZCacheEntity*)entity withFormatName:(NSString *)formatName completionBlock:(FICImageRequestCompletionBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSURL *fileUrl = [entity sourceImageURLWithFormatName:formatName];
        UIImage *source = fileUrl ? [UIImage imageWithContentsOfFile:fileUrl.path] : nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(source);
        });
    });
}

- (BOOL)imageCache:(FICImageCache *)imageCache shouldProcessAllFormatsInFamily:(NSString *)formatFamily forEntity:(id<FICEntity>)entity {
    return NO;
}

- (void)imageCache:(FICImageCache *)imageCache errorDidOccurWithMessage:(NSString *)errorMessage {
    DDLogError(@"[cache] cache error occured: %@", errorMessage);
}

@end
