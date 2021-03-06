//
//  SZNewsFeedTableViewCell.h
//  VKSampleApp
//
//  Created by Сергей Галездинов on 26.06.15.
//  Copyright (c) 2015 Сергей Галездинов. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SZNewsFeedTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UILabel *username;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *likesCountLabel;
@property (strong, nonatomic) IBOutlet UIImageView *likeImage;
@property (strong, nonatomic) IBOutlet UILabel *repostsCountLabel;
@property (strong, nonatomic) IBOutlet UIImageView *repostImage;
@property (strong, nonatomic) IBOutlet UILabel *postMessageText;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIView *picturePlaceholder;
@end
