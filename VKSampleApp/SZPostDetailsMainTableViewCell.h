//
//  SZPostDetailsMainTableViewCell.h
//  VKSampleApp
//
//  Created by Сергей Галездинов on 27.06.15.
//  Copyright (c) 2015 Сергей Галездинов. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SZPostDetailsMainTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageTextLabel;
@property (strong, nonatomic) IBOutlet UIImageView *likeImageView;
@property (strong, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (strong, nonatomic) IBOutlet UIImageView *repostImageView;
@property (strong, nonatomic) IBOutlet UILabel *repostCountLabel;

@end
