//
//  ViewController.m
//  VKSampleApp
//
//  Created by Сергей Галездинов on 24.06.15.
//  Copyright (c) 2015 Сергей Галездинов. All rights reserved.
//

#import "SZNewsFeedViewController.h"
#import <PSTAlertController.h>

@interface SZNewsFeedViewController ()<UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate>

@end

@implementation SZNewsFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)logoutPressed:(id)sender {
    PSTAlertController *logoutSheet = [PSTAlertController actionSheetWithTitle:nil];
    [logoutSheet addAction:[PSTAlertAction actionWithTitle:NSLocalizedString(@"Logout", "logout action item title")
                                                     style:PSTAlertActionStyleDestructive
                                                   handler:^(PSTAlertAction *action) {
        [self.serverController logOut];
    }]];

    [logoutSheet addCancelActionWithHandler:nil];
    [logoutSheet showWithSender:self controller:self animated:YES completion:nil];
}

@end
