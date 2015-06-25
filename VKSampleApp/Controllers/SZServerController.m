//
//  SZServerController.m
//  VKSampleApp
//
//  Created by Сергей Галездинов on 25.06.15.
//  Copyright (c) 2015 Сергей Галездинов. All rights reserved.
//

#import "SZServerController.h"
#import <VKSdk.h>

@interface SZServerController()<VKSdkDelegate>

@end

@implementation SZServerController
{
    dispatch_block_t _loginSuccess;
    void(^_loginFailure)(NSError *error);
}
#pragma mark init

- (instancetype)init
{
    self = [super init];
    if (self) {
        [VKSdk initializeWithDelegate:self andAppId:@"4969806"];
        [VKSdk wakeUpSession];
    }
    return self;
}

#pragma mark helper methods

-(void) doVKAuth
{
    DDLogVerbose(@"[server] vk token is expired or not exist. requesting fresh auth");

    [VKSdk authorize:@[VK_PER_FRIENDS, VK_PER_PHOTOS, VK_PER_WALL]
        revokeAccess:NO
          forceOAuth:NO
               inApp:![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"vkauthorize://authorize"]]];
}

#pragma mark public methods

-(BOOL)isUserLoggedIn {
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

-(BOOL) processOpenURL:(NSURL*)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [VKSdk processOpenURL:url fromApplication:sourceApplication];
}

#pragma mark vk sdk delegate

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    UIViewController *topVC = [[UIApplication sharedApplication].windows[0] rootViewController];
    VKCaptchaViewController *vc = [VKCaptchaViewController captchaControllerWithError:captchaError];
    [vc presentIn:topVC];
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken
{
    [self logOut];
}

- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken
{
    if (_loginSuccess) {
        _loginSuccess();
        _loginSuccess = nil;
        _loginFailure = nil;
    }
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller
{
    UIViewController *topVC = [[UIApplication sharedApplication].windows[0] rootViewController];
    [topVC presentViewController:controller animated:YES completion:nil];
}

- (void)vkSdkAcceptedUserToken:(VKAccessToken *)token
{
    [self vkSdkReceivedNewToken:token];
}

- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError
{
    DDLogError(@"[social] vk error occured: %@ (%@/%@): %@", authorizationError.errorMessage, @(authorizationError.errorCode), authorizationError.errorReason, authorizationError.httpError);
    if (_loginFailure) {
        _loginFailure([NSError errorWithDomain:[NSBundle mainBundle].bundleIdentifier
                                          code:authorizationError.errorCode
                                      userInfo:@{@"error" : authorizationError}]);
    }

}

-(BOOL)vkSdkIsBasicAuthorization
{
    return YES;
}

@end
