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

/**
 Wrapper for VK API requests and login state
 */
@interface SZServerController : NSObject

@property (weak) id<SZServerControllerDelegate> delegate;

@property (readonly) BOOL isUserLoggedIn;

/**
 Validate user credentials on server
 @param
 user user email
 @param
 password user password
 @param
 successBlock block to be called on successfull validation
 @param
 failure block to be called when error occurs: invalid credentials, no internet connection etc.

 */
- (void)loginWith:(NSString*)user password:(NSString*)password success:(dispatch_block_t)successBlock failure:(void(^)(NSError *error))failure;

/**
 Perform user logout. After succesfull completion, `userDidLogout` delegate method will be called.
 */
- (void)logOut;

//TODO: implement feed request
@end
