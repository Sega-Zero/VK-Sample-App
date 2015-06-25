//
//  SZImageLoader.h
//  VKSampleApp
//
//  Created by Сергей Галездинов on 25.06.15.
//  Copyright (c) 2015 Сергей Галездинов. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SZImageLoader : NSObject

- (void) downloadImageWithURL:(NSString*)url toFilePath:(NSString*)filePath completionHandler:(void(^)(NSError *error, NSString *url))completionHandler;

@end
