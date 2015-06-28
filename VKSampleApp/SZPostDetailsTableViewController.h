//
//  SZPostDetailsTableViewController.h
//  VKSampleApp
//
//  Created by Сергей Галездинов on 27.06.15.
//  Copyright (c) 2015 Сергей Галездинов. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SZModel.h"
#import "SZVKImageManager.h"

@interface SZPostDetailsTableViewController : UITableViewController

@property (nonatomic) SZPost *post;
@property (weak, nonatomic) SZVKImageManager *imageManager;

@end
