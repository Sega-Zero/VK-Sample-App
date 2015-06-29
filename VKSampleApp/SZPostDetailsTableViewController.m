//
//  SZPostDetailsTableViewController.m
//  VKSampleApp
//
//  Created by Сергей Галездинов on 27.06.15.
//  Copyright (c) 2015 Сергей Галездинов. All rights reserved.
//

#import "SZPostDetailsTableViewController.h"
#import "SZPostDetailsMainTableViewCell.h"
#import "SZPostDetailsPhotoTableViewCell.h"
#import <NSAttributedString+DDHTML.h>
#import "SZModel+Extensions.h"

@interface SZPostDetailsTableViewController ()

@end

@implementation SZPostDetailsTableViewController
{
    NSCache *_fullSizeImagesCache;
}

#pragma mark viewcontroller

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [_fullSizeImagesCache removeAllObjects];
    _fullSizeImagesCache = [[NSCache alloc] init];
}

#pragma mark setters

- (void)setPost:(SZPost *)post {
    _post = post;

    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.post.photos.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;

    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"DetailTextCellID" forIndexPath:indexPath];
        [self configureMainCell:(SZPostDetailsMainTableViewCell*)cell];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"DetailImageCellID" forIndexPath:indexPath];
        [self configurePhotoCell:(SZPostDetailsPhotoTableViewCell*)cell atIndexPath:indexPath];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row > 0) {
        SZPhoto *photo = [self.post.photos objectAtIndex:indexPath.row - 1];
        CGFloat width = photo.widthValue;
        CGFloat height = photo.heightValue;

        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        CGFloat multiplier = screenSize.width / width;

        CGFloat result = (height * multiplier);
        return result + 16;
    }

    static SZPostDetailsMainTableViewCell *mainCellCached = nil;
    if (!mainCellCached) {
        mainCellCached = [tableView dequeueReusableCellWithIdentifier:@"DetailTextCellID"];
    };
    [self configureMainCell:mainCellCached];

    mainCellCached.contentView.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(self.tableView.frame));

    [mainCellCached.contentView setNeedsLayout];
    [mainCellCached.contentView layoutIfNeeded];

    CGFloat height = [mainCellCached.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;

    return height + 1/*separator*/;
}

- (void)configureMainCell:(SZPostDetailsMainTableViewCell*)cell {
    cell.messageTextLabel.attributedText = self.post.text;
    cell.usernameLabel.text = self.post.author.name ?: @"";

    cell.timeLabel.text = [NSDateFormatter localizedStringFromDate:self.post.date
                                                         dateStyle:NSDateFormatterShortStyle
                                                         timeStyle:NSDateFormatterMediumStyle];

    cell.likeImageView.hidden = self.post.likesCountValue == 0;
    cell.likeCountLabel.hidden = self.post.likesCountValue == 0;
    cell.likeCountLabel.text = [NSString stringWithFormat:@"%@", self.post.likesCount];

    cell.repostImageView.hidden = self.post.repostCountValue == 0;
    cell.repostCountLabel.hidden = self.post.repostCountValue == 0;
    cell.repostCountLabel.text = [NSString stringWithFormat:@"%@", self.post.repostCount];

    [self.imageManager setImageFromUser:self.post.author to:cell.avatarImageView];
}

- (void)configurePhotoCell:(SZPostDetailsPhotoTableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath {

    SZPhoto *photo = [self.post.photos objectAtIndex:indexPath.row - 1];
    UIImage *photoImage = [_fullSizeImagesCache objectForKey:[photo fullImagePath]];
    if (!photoImage) {
        cell.postImageView.image = nil;
        [self.imageManager loadFullImageFromPhoto:photo completionHandler:^(UIImage *image) {
            if (image) {
                [_fullSizeImagesCache setObject:image forKey:[photo fullImagePath]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.postImageView.image = image;
                });
            }
        }];
    } else {
        cell.postImageView.image = photoImage;
    }
}

@end
