//
//  SZAdjustLabel.m
//  VKSampleApp
//
//  Created by Сергей Галездинов on 27.06.15.
//  Copyright (c) 2015 Сергей Галездинов. All rights reserved.
//

#import "SZAdjustLabel.h"

@implementation SZAdjustLabel

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];

    if (self.numberOfLines == 0 && bounds.size.width != self.preferredMaxLayoutWidth) {
        self.preferredMaxLayoutWidth = self.bounds.size.width;
        [self setNeedsUpdateConstraints];
    }
}

@end
