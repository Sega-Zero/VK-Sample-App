//
//  SZLoginViewController.h
//  VKSampleApp
//
//  Created by Сергей Галездинов on 25.06.15.
//  Copyright (c) 2015 Сергей Галездинов. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SZLoginViewControllerDelegate <NSObject>

- (void) startLoginProcessWithCompletionHandler:(void(^)(NSError *error))completionHandler;

@end

@interface SZLoginViewController : UIViewController

@property (weak) id<SZLoginViewControllerDelegate> delegate;

@end
