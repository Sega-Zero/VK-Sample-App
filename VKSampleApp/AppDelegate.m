//
//  AppDelegate.m
//  VKSampleApp
//
//  Created by Сергей Галездинов on 24.06.15.
//  Copyright (c) 2015 Сергей Галездинов. All rights reserved.
//

#import "AppDelegate.h"
#import "SZLocalStorage.h"
#import "SZServerController.h"
#import "SZLoginViewController.h"
#import "SZNewsFeedViewController.h"
#import <CocoaLumberjack.h>
#import <DDTTYLogger.h>
#import <DDFileLogger.h>
#import "SZVKImageManager.h"

@interface AppDelegate ()<SZServerControllerDelegate, SZLoginViewControllerDelegate>

@end

@implementation AppDelegate
{
    SZLocalStorage *_localStorage;
    SZServerController *_serverController;
    SZVKImageManager *_imageManager;
}

#pragma mark app lifetime 

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#if DEBUG
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:DDLogLevelDebug];
    DDFileLogger* ff = [[DDFileLogger alloc] init];
    ff.doNotReuseLogFiles = YES;
    ff.maximumFileSize = 0;
    [ff.logFileManager setMaximumNumberOfLogFiles:100];
    [DDLog addLogger:ff withLevel:DDLogLevelAll];
#endif

    [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationPortrait;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    _localStorage = [SZLocalStorage new];
    _serverController = [SZServerController new];
    _serverController.delegate = self;

    _imageManager = [SZVKImageManager new];

    [self switchStoryBoardTo:_serverController.isUserLoggedIn ? @"Main" : @"Login"];
    [self ensureDatabaseIsNotEmpty];

    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [_localStorage cleanUpStack];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
 {
     return [_serverController processOpenURL:url sourceApplication:sourceApplication annotation:annotation];
}

#pragma mark helper methods

- (void)switchStoryBoardTo:(NSString*)storyboardName {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    UIViewController *rootVC = [storyboard instantiateInitialViewController];
    self.window.rootViewController = rootVC;

    if ([rootVC isKindOfClass:[UINavigationController class]]) {
        SZNewsFeedViewController *newsVC = (SZNewsFeedViewController*)[(UINavigationController*)rootVC topViewController];
        newsVC.serverController = _serverController;
        newsVC.localStorage = _localStorage;
        newsVC.imageManager = _imageManager;
    }
    if ([rootVC isKindOfClass:[SZLoginViewController class]]) {
        SZLoginViewController *loginVC = (SZLoginViewController*)rootVC;
        loginVC.delegate = self;
    }
}

- (void)ensureDatabaseIsNotEmpty {
    if ([_localStorage isEmpty]) {
        [_serverController fetchNewsFeedFrom:nil dataHandler:^(NSError *error, NSArray *users, NSDictionary *postsMap) {
            if (!error) {
                [_localStorage addPosts:postsMap fromUsers:users completionHandler:nil];
            }
        }];
    }
}

#pragma mark servercontroller delegate

-(void)userDidLogout {
    [self switchStoryBoardTo:@"Login"];
    [_localStorage removeAllRecords];
    [_imageManager cleanup];
}

#pragma mark loginview delegate

-(void)startLoginProcessWithCompletionHandler:(void (^)(NSError *))completionHandler {
    [_serverController loginWithSuccess:^{
        [self ensureDatabaseIsNotEmpty];
        completionHandler(nil);
        [self switchStoryBoardTo:@"Main"];
    } failure:^(NSError *error) {
        completionHandler(error);
    }];
}

@end
