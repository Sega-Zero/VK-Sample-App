//
//  SZLocalStorage.h
//  VKSampleApp
//
//  Created by Сергей Галездинов on 24.06.15.
//  Copyright (c) 2015 Сергей Галездинов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SZModel.h"

/**
 Wrapper over Core Data model. The general purpose of it is to store newsfeed, users and comments
 */
@interface SZLocalStorage : NSObject

/**
 NSFetchedResultsController to be used in newsfeed UI
 */
- (NSFetchedResultsController *)newsFeedFetchedResultsController;

/**
 Clean up Magical Record Stack
 */
- (void)cleanUpStack;

/**
 Clear all database entries
 */
- (void)removeAllRecords;

//TODO: add users and feed

@end
