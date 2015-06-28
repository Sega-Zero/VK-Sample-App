//
//  SZModel+Extensions.h
//  VKSampleApp
//
//  Created by Сергей Галездинов on 28.06.15.
//  Copyright (c) 2015 Сергей Галездинов. All rights reserved.
//

#import "SZModel.h"

@interface SZPhoto (Extensions)

- (NSString*)fullImagePath;
- (NSString*)thumbnailImagePath;

@end

@interface SZUser (Extensions)

- (NSString*)avatarImagePath;

@end
