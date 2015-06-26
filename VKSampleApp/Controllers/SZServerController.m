//
//  SZServerController.m
//  VKSampleApp
//
//  Created by Сергей Галездинов on 25.06.15.
//  Copyright (c) 2015 Сергей Галездинов. All rights reserved.
//

#import "SZServerController.h"
#import <VKSdk.h>
#import <AFNetworking.h>

@interface SZServerController()<VKSdkDelegate>

@end

@implementation SZServerController
{
    dispatch_block_t _loginSuccess;
    void(^_loginFailure)(NSError *error);

    AFHTTPSessionManager *_manager;
}

static NSString * const VK_API_URL = @"https://api.vk.com";

#pragma mark init

- (instancetype)init
{
    self = [super init];
    if (self) {
        [VKSdk initializeWithDelegate:self andAppId:@"4969806"];
        [VKSdk wakeUpSession];

        _manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:VK_API_URL]];
        _manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    }
    return self;
}

#pragma mark helper methods

- (void)doVKAuth
{
    DDLogVerbose(@"[server] vk token is expired or not exist. requesting fresh auth");

    [VKSdk authorize:@[VK_PER_FRIENDS, VK_PER_PHOTOS, VK_PER_WALL]
        revokeAccess:NO
          forceOAuth:NO
               inApp:![VKSdk vkAppMayExists]];
}

- (void)fetchNewsStartDate:(NSDate*)startDate endDate:(NSDate*)endDate dataHandler:(SZVKDataRequestBlock)dataHandler {

    if (![VKSdk getAccessToken]) {
        [self logOut];
        return;
    }

    NSMutableDictionary *params = [@{VK_API_ACCESS_TOKEN : [VKSdk getAccessToken].accessToken,
                                     @"max_photos" : @10,
                                     @"source_ids" : @"friends,following",
                                     @"filter"     : @"post,photo",
                                     @"count"      : @100} mutableCopy];
    if (startDate) {
        [params setValue:[NSString stringWithFormat:@"%f", [startDate timeIntervalSince1970]] forKey:@"start_time"];
    }
    if (endDate) {
        [params setValue:[NSString stringWithFormat:@"%f", [endDate timeIntervalSince1970]] forKey:@"end_time"];
    }

    [_manager GET:@"method/newsfeed.get" parameters:params success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
        if (!responseObject || responseObject[@"error"]) {
            DDLogError(@"[server] error during newsfeed request: %@", responseObject);

            NSError *error = [NSError errorWithDomain:[NSBundle mainBundle].bundleIdentifier code:[responseObject[@"error"][@"error_code"] integerValue] userInfo:nil];
            dataHandler(error, nil, nil);
            return;
        }

        NSDictionary *response = responseObject[@"response"];
        NSArray *profiles = response[@"profiles"];
        NSArray *posts = response[@"items"];
        NSMutableDictionary *postsMap = [NSMutableDictionary dictionaryWithCapacity:profiles.count];
        for (NSDictionary *post in posts) {
            NSString *key = [NSString stringWithFormat:@"%@", post[@"source_id"] ?: @""];
            NSMutableArray *postsArray = postsMap[key];
            if (!postsArray) {
                postsArray = [NSMutableArray new];
                postsMap[key] = postsArray;
            }
            [postsArray addObject:post];
        }
        dataHandler(nil, profiles, postsMap);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogError(@"[server] error during newsfeed request: %@", error);
        dataHandler(error, nil, nil);
    }];
}

#pragma mark public methods

- (BOOL)isUserLoggedIn {
    return [VKSdk isLoggedIn];
}

- (void)loginWithSuccess:(dispatch_block_t)successBlock failure:(void(^)(NSError *error))failure {
    _loginSuccess = successBlock;
    _loginFailure = failure;
    [self doVKAuth];
}

- (void)logOut {
    [VKSdk forceLogout];

    if (self.delegate) {
        [self.delegate userDidLogout];
    }
}

- (BOOL)processOpenURL:(NSURL*)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [VKSdk processOpenURL:url fromApplication:sourceApplication];
}

- (void)fetchNewsFeedSince:(NSDate*)date dataHandler:(SZVKDataRequestBlock)dataHandler {
    [self fetchNewsStartDate:nil endDate:date dataHandler:dataHandler];
}

- (void)fetchNewsFeedFrom:(NSDate*)date dataHandler:(SZVKDataRequestBlock)dataHandler {
    [self fetchNewsStartDate:date endDate:nil dataHandler:dataHandler];
}

#pragma mark vk sdk delegate

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    UIViewController *topVC = [[UIApplication sharedApplication].windows[0] rootViewController];
    VKCaptchaViewController *vc = [VKCaptchaViewController captchaControllerWithError:captchaError];
    [vc presentIn:topVC];
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
    [self logOut];
}

- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {
    if (_loginSuccess) {
        _loginSuccess();
        _loginSuccess = nil;
        _loginFailure = nil;
    }
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    UIViewController *topVC = [[UIApplication sharedApplication].windows[0] rootViewController];
    [topVC presentViewController:controller animated:YES completion:nil];
}

- (void)vkSdkAcceptedUserToken:(VKAccessToken *)token {
    [self vkSdkReceivedNewToken:token];
}

- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError {
    DDLogError(@"[server] vk error occured: %@ (%@/%@): %@", authorizationError.errorMessage, @(authorizationError.errorCode), authorizationError.errorReason, authorizationError.httpError);
    if (_loginFailure) {
        _loginFailure([NSError errorWithDomain:[NSBundle mainBundle].bundleIdentifier
                                          code:authorizationError.errorCode
                                      userInfo:@{@"error" : authorizationError}]);
    }
}

-(BOOL)vkSdkIsBasicAuthorization {
    return YES;
}

@end
