//
//  SZServerController.h
//  VKSampleApp
//
//  Created by Сергей Галездинов on 25.06.15.
//  Copyright (c) 2015 Сергей Галездинов. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SZServerControllerDelegate <NSObject>

- (void)userDidLogout;

@end

typedef void(^SZVKDataRequestBlock)(NSError *error, NSArray *users, NSDictionary *postsMap);

/**
 Wrapper for VK API requests and login state
 */
@interface SZServerController : NSObject

@property (weak) id<SZServerControllerDelegate> delegate;

@property (readonly) BOOL isUserLoggedIn;

/**
 Sign in to vk server via installed app or webbrowser instance
 @param
 successBlock block to be called on success
 @param
 failure block to be called when error occurs: invalid credentials, no internet connection etc.

 */
- (void)loginWithSuccess:(dispatch_block_t)successBlock failure:(void(^)(NSError *error))failure;

/**
 Perform user logout. After succesfull completion, `userDidLogout` delegate method will be called.
 */
- (void)logOut;

/**
 Method to process openURL from vk app
 */
- (BOOL)processOpenURL:(NSURL*)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

/**
 Request new newsfeed data from server since specified date.
 @param
 date request new posts before this date
 @param
 dataHandler block to be called on completion
 @note
 Passing nil to date parameter will request the last 50 posts from feed
 */
- (void)fetchNewsFeedSince:(NSDate*)date dataHandler:(SZVKDataRequestBlock)dataHandler;
/**
 Request previous newsfeed data from server until specified date.
 @param
 date request old posts until this date
 @param
 dataHandler block to be called on completion
 @note
 Passing nil to date parameter will request the last 50 posts from feed
 */
- (void)fetchNewsFeedFrom:(NSDate*)date dataHandler:(SZVKDataRequestBlock)dataHandler;

@end
