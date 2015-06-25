//
//  SZLocalStorage.m
//  VKSampleApp
//
//  Created by Сергей Галездинов on 24.06.15.
//  Copyright (c) 2015 Сергей Галездинов. All rights reserved.
//

#import "SZLocalStorage.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import <MagicalRecord/MagicalRecord.h>

@implementation SZLocalStorage

#pragma mark init 

-(instancetype)init {
    self = [super init];
    if (self) {
        [MagicalRecord setupAutoMigratingCoreDataStack];
    }
    return self;
}

-(void)dealloc {
    [self cleanUpStack];
}

#pragma mark public methods

- (NSFetchedResultsController *)newsFeedFetchedResultsController {
    //TODO: implement
    return nil;
}

-(void)cleanUpStack {
    [MagicalRecord cleanUp];
}

-(void)removeAllRecords {
//TODO: implement
}

@end
