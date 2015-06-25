//
//  ViewController.h
//  VKSampleApp
//
//  Created by Сергей Галездинов on 24.06.15.
//  Copyright (c) 2015 Сергей Галездинов. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface SZNewsFeedViewController : UITableViewController

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

