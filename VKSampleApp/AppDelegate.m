//
//  AppDelegate.m
//  VKSampleApp
//
//  Created by Сергей Галездинов on 24.06.15.
//  Copyright (c) 2015 Сергей Галездинов. All rights reserved.
//

#import "AppDelegate.h"
#import "SZLocalStorage.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
{
    SZLocalStorage *_localStorage;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _localStorage = [SZLocalStorage new];
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [_localStorage cleanUpStack];
}

@end
