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

@interface SZPostDetailsTableViewController ()

@end

@implementation SZPostDetailsTableViewController

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.post.photos.count + 1;;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;

    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"DetailTextCellID" forIndexPath:indexPath];
        [self configureMainCell:(SZPostDetailsMainTableViewCell*)cell];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"DetailImageCellID" forIndexPath:indexPath];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cacheCell = nil;

    static SZPostDetailsMainTableViewCell *mainCellCached = nil;
    if (!mainCellCached) {
        mainCellCached = [tableView dequeueReusableCellWithIdentifier:@"DetailTextCellID"];
    };
    static SZPostDetailsPhotoTableViewCell *photoCellCached = nil;
    if (!photoCellCached) {
        photoCellCached = [tableView dequeueReusableCellWithIdentifier:@"DetailImageCellID"];
    };

    if (indexPath.row == 0) {
        [self configureMainCell:mainCellCached];
        cacheCell = mainCellCached;
    } else {
        [self configurePhotoCell:photoCellCached atIndexPath:indexPath];
        cacheCell = photoCellCached;
    }

    cacheCell.contentView.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.frame),CGRectGetHeight(self.tableView.frame));

    [cacheCell.contentView setNeedsLayout];
    [cacheCell.contentView layoutIfNeeded];

    CGFloat height = [cacheCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;

    return height + 1/*separator*/;
}

- (void)configureMainCell:(SZPostDetailsMainTableViewCell*)cell {
    cell.messageTextLabel.attributedText = [NSAttributedString attributedStringFromHTML:self.post.text ?: @""];
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
}

- (void)configurePhotoCell:(SZPostDetailsPhotoTableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.imageView.image = [UIImage imageNamed:@"logo"];
}

@end
