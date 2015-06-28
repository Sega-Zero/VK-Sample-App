//
//  ViewController.h
//  VKSampleApp
//
//  Created by Сергей Галездинов on 24.06.15.
//  Copyright (c) 2015 Сергей Галездинов. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SZServerController.h"
#import "SZLocalStorage.h"

@interface SZNewsFeedViewController : UITableViewController

@property (weak, nonatomic) SZServerController *serverController;
@property (weak, nonatomic) SZLocalStorage *localStorage;

@end

