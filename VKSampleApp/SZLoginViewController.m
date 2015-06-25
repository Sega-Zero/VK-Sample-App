//
//  SZLoginViewController.m
//  VKSampleApp
//
//  Created by Сергей Галездинов on 25.06.15.
//  Copyright (c) 2015 Сергей Галездинов. All rights reserved.
//

#import "SZLoginViewController.h"
#import <PSTAlertController.h>
#import <Reachability.h>

@interface SZLoginViewController ()

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loginSpinner;

@end

@implementation SZLoginViewController

- (IBAction)loginButtonPressed:(id)sender {
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    if (![reach isReachable]) {
        [PSTAlertController presentDismissableAlertWithTitle:NSLocalizedString(@"Error", "error titile for alerts")
                                                     message:NSLocalizedString(@"No internet connection.", "error text for no internet alert")
                                                  controller:self];
        return;
    }

    if (self.delegate) {
        self.loginSpinner.hidden = NO;
        [self.delegate startLoginProcessWithCompletionHandler:^(NSError *error) {
            self.loginSpinner.hidden = YES;
            if (error) {
                [PSTAlertController presentDismissableAlertWithTitle:NSLocalizedString(@"Error", "error titile for alerts")
                                                             message:NSLocalizedString(@"Couldn't sign in to vk. Please try again later", "error text for login error alert")
                                                          controller:self];
            }
        }];
    }
}
@end
