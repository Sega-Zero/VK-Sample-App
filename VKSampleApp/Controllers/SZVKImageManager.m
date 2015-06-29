//
//  SZVKImageManager.m
//  VKSampleApp
//
//  Created by Сергей Галездинов on 25.06.15.
//  Copyright (c) 2015 Сергей Галездинов. All rights reserved.
//

#import "SZVKImageManager.h"
#import "SZImageDownloader.h"
#import "SZModel+Extensions.h"
#import "SZImageCache.h"
#import "objc/runtime.h"

@interface UIImageView (ImagePath)

- (NSString *)imagePath;
- (void)setImagePath:(NSString*)imagePath;

@end

@implementation UIImageView (ImagePath)

static char imagePathKey;

- (NSString *)imagePath {
    return objc_getAssociatedObject(self, &imagePathKey);
}

- (void)setImagePath:(NSString*)imagePath {
    objc_setAssociatedObject(self, &imagePathKey, imagePath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation SZVKImageManager
{
    SZImageDownloader *_avatarsLoader;
    SZImageDownloader *_postImagesLoader;

    SZImageCache *_avatarsCache;
    SZImageCache *_postThumbnailsCache;
}

#pragma mark init

- (instancetype)init
{
    self = [super init];
    if (self) {
        _avatarsLoader = [[SZImageDownloader alloc] initWithQueueLimit:10];
        _postImagesLoader = [[SZImageDownloader alloc] initWithQueueLimit:4];

        _avatarsCache = [[SZImageCache alloc] initWithSize:CGSizeMake(35, 35) maxCacheCount:1000];
        _postThumbnailsCache = [[SZImageCache alloc] initWithSize:CGSizeMake(150, 150) maxCacheCount:500];
    }
    return self;
}

#pragma mark internal methods

- (void) setImageFromPath:(NSString*)imagePath
                    cache:(SZImageCache*)cache
                   loader:(SZImageDownloader*)loader
              downloadURL:(NSString*)downloadURL
         placeholderImage:(UIImage*)placeholderImage
                       to:(UIImageView*)imageView {

    if (![[imageView imagePath] isEqualToString:imagePath] || !imageView.image) {
        [imageView setImagePath:imagePath];

        __block UIImage *loadedImage = nil;
        __weak typeof(imageView) weakImageView = imageView;

        [cache loadImageWithPath:imagePath completionHandler:^(UIImage *image, NSString *loadPath) {
            if (image) {
                loadedImage = image;

                if ([[weakImageView imagePath] isEqualToString:imagePath]) {
                    weakImageView.image = image;
                }

            } else {
                [loader downloadImageWithURL:downloadURL
                                  toFilePath:imagePath
                           completionHandler:^(NSError *error, NSString *url) {
                               if (!error && [url isEqualToString:downloadURL]) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [weakImageView setImagePath:nil];
                                       [self setImageFromPath:imagePath
                                                        cache:cache
                                                       loader:loader
                                                  downloadURL:downloadURL
                                             placeholderImage:placeholderImage
                                                           to:imageView];
                                   });
                               } else {
                                   DDLogError(@"[imageman] couldn't download image from \"%@\" with error: %@", url, error);
                               }
                           }];
            }
        }];

        if (!loadedImage) {
            imageView.image = placeholderImage;
        }

    }
}

#pragma mark public methods

- (void)setImageFromUser:(SZUser *)user to:(UIImageView *)imageView {
    //TODO: another placeholder image
    [self setImageFromPath:[user avatarImagePath]
                     cache:_avatarsCache
                    loader:_avatarsLoader
               downloadURL:user.avatarURI
          placeholderImage:[UIImage imageNamed:@"logo"]
                        to:imageView];
}

- (void)setThumbnailImageFromPhoto:(SZPhoto *)photo to:(UIImageView *)imageView {
    [self setImageFromPath:[photo thumbnailImagePath]
                     cache:_postThumbnailsCache
                    loader:_postImagesLoader
               downloadURL:photo.thumbnailURI
          placeholderImage:[UIImage imageNamed:@"logo"]
                        to:imageView];
}

- (void)loadFullImageFromPhoto:(SZPhoto*)photo completionHandler:(void(^)(UIImage *image))completionHandler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        UIImage *postImage = [UIImage imageWithContentsOfFile:[photo fullImagePath]];
        if (!postImage) {
            [_postImagesLoader downloadImageWithURL:[photo photoURI]
                                         toFilePath:[photo fullImagePath]
                                  completionHandler:^(NSError *error, NSString *url) {
                                      if (!error && [url isEqualToString:[photo photoURI]]) {
                                          [self loadFullImageFromPhoto:photo completionHandler:completionHandler];
                                      } else {
                                          DDLogError(@"[imageman] couldn't download image from \"%@\" with error: %@", url, error);
                                      }
                                  }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionHandler) {
                    completionHandler(postImage);
                }
            });
        }
    });
}

- (void)cleanup {
    [_avatarsLoader cancel];
    [_postImagesLoader cancel];

    [_avatarsCache clearCache];
    [_postThumbnailsCache clearCache];

    NSError *error = nil;
    if (![[NSFileManager defaultManager] removeItemAtPath:[SZImageCache cacheDirectory] error:&error] || error) {
        DDLogError(@"[imageman] couldn't remove cache images with error: %@", error);
    };
}

@end
