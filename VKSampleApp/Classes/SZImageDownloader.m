//
//  SZImageDownloader.m
//  VKSampleApp
//
//  Created by Сергей Галездинов on 28.06.15.
//  Copyright (c) 2015 Сергей Галездинов. All rights reserved.
//

#import "SZImageDownloader.h"
#import <AFNetworking.h>

@implementation SZImageDownloader
{
    NSUInteger _queueLimit;
    AFHTTPSessionManager *_manager;
}

#pragma mark init

- (instancetype)initWithQueueLimit:(NSUInteger)queueLimit
{
    self = [super init];
    if (self) {
        _queueLimit = queueLimit;
    }
    return self;
}

#pragma mark public methods

- (void)downloadImageWithURL:(NSString*)url toFilePath:(NSString*)filePath completionHandler:(void(^)(NSError *error, NSString *url))completionHandler {

    if (!_manager) {
        _manager = [[AFHTTPSessionManager alloc] init];
        _manager.operationQueue.maxConcurrentOperationCount = _queueLimit;
        _manager.responseSerializer.acceptableContentTypes = nil;
        _manager.securityPolicy.allowInvalidCertificates = YES;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];

    NSURLSessionDownloadTask *task = [_manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {

        return [NSURL fileURLWithPath:filePath];

    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (completionHandler) {
            completionHandler(error, url);
        }
    }];

    [task resume];
}

- (void)cancel {
    [_manager invalidateSessionCancelingTasks:YES];
    _manager = nil;
}
@end
