//
//  ViewController.m
//  VKSampleApp
//
//  Created by Сергей Галездинов on 24.06.15.
//  Copyright (c) 2015 Сергей Галездинов. All rights reserved.
//

#import "SZNewsFeedViewController.h"
#import <PSTAlertController.h>
#import "SZNewsFeedTableViewCell.h"
#import "SZPostDetailsTableViewController.h"
#import "SZNewsFeedCollectionViewCell.h"
#import <CCBottomRefreshControl/UIScrollView+BottomRefreshControl.h>

@interface SZNewsFeedViewController ()<UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation SZNewsFeedViewController
{
    NSFetchedResultsController *_fetchedResultsController;
    SZNewsFeedTableViewCell *_cacheSizeCell;
    BOOL _oldPostsLoading;
    NSDateFormatter *_dateFormatter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIRefreshControl *topRefreshControl = [UIRefreshControl new];
    [topRefreshControl addTarget:self action:@selector(loadFreshPosts:) forControlEvents:UIControlEventValueChanged];
    topRefreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Pull down to load fresh posts", "hint text for top refresh control")];

    UIRefreshControl *bottomRefreshControl = [UIRefreshControl new];
    [bottomRefreshControl addTarget:self action:@selector(loadOlderPosts:) forControlEvents:UIControlEventValueChanged];
    bottomRefreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Pull up to load older posts", "hint text for bottom refresh control")];
    bottomRefreshControl.triggerVerticalOffset = 100.;

    self.refreshControl = topRefreshControl;
    self.tableView.bottomRefreshControl = bottomRefreshControl;

    _oldPostsLoading = NO;

    NSString *format = [NSDateFormatter dateFormatFromTemplate:@"dd:mm:hh MMMYYYY" options:0 locale:[NSLocale autoupdatingCurrentLocale]];
    _dateFormatter = [[NSDateFormatter alloc] init];
    _dateFormatter.dateFormat = format;
}

#pragma mark setters and actions

- (IBAction)logoutPressed:(id)sender {
    PSTAlertController *logoutSheet = [PSTAlertController actionSheetWithTitle:nil];
    [logoutSheet addAction:[PSTAlertAction actionWithTitle:NSLocalizedString(@"Logout", "logout action item title")
                                                     style:PSTAlertActionStyleDestructive
                                                   handler:^(PSTAlertAction *action) {
        [self.serverController logOut];
    }]];

    [logoutSheet addCancelActionWithHandler:nil];
    [logoutSheet showWithSender:self controller:self animated:YES completion:nil];
}

- (void)setLocalStorage:(SZLocalStorage *)localStorage {
    _localStorage = localStorage;
    [self.tableView reloadData];
}

- (IBAction)loadFreshPosts:(id)sender {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    SZPost *post = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    [self.serverController fetchNewsFeedFrom:post.date dataHandler:^(NSError *error, NSArray *users, NSDictionary *postsMap) {
        if (!error) {
            [self.localStorage addPosts:postsMap fromUsers:users completionHandler:^{
                [self.refreshControl endRefreshing];
            }];
        } else {
            [self.refreshControl endRefreshing];
        }
    }];
}

- (IBAction)loadOlderPosts:(id)sender {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self tableView:self.tableView numberOfRowsInSection:0] - 1 inSection:0];
    SZPost *post = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    [self.serverController fetchNewsFeedSince:post.date dataHandler:^(NSError *error, NSArray *users, NSDictionary *postsMap) {
        _oldPostsLoading = YES;
        if (!error) {
            [self.localStorage addPosts:postsMap fromUsers:users completionHandler:^{
                [self.tableView.bottomRefreshControl endRefreshing];
                [self.tableView reloadData];
                _oldPostsLoading = NO;
            }];
        } else {
            [self.tableView.bottomRefreshControl endRefreshing];
        }
    }];
}

#pragma mark Storyboard

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showDetailsSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *post = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [(SZPostDetailsTableViewController*)segue.destinationViewController setImageManager:self.imageManager];
        [(SZPostDetailsTableViewController*)segue.destinationViewController setPost:(SZPost*)post];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[[self fetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsController] sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SZNewsFeedTableViewCell *cell = (SZNewsFeedTableViewCell*) [tableView dequeueReusableCellWithIdentifier:@"FeedCellID" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath isOffScreen:NO];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 250;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (!_cacheSizeCell) {
        _cacheSizeCell = [tableView dequeueReusableCellWithIdentifier:@"FeedCellID"];
    };

    [self configureCell:_cacheSizeCell atIndexPath:indexPath isOffScreen:YES];

    _cacheSizeCell.contentView.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.frame),CGRectGetHeight(self.tableView.frame));

    [_cacheSizeCell.contentView setNeedsLayout];
    [_cacheSizeCell.contentView layoutIfNeeded];

    CGFloat height = [_cacheSizeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;

    SZPost *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    if (object.photos.count > 0) {
        height += 150;
    }
    return height + 1/*separator*/;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(SZNewsFeedTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    SZPost *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    if (object.photos.count > 0) {
        cell.picturesHeightConstraint.constant = 150;
        [cell.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    } else {
        cell.picturesHeightConstraint.constant = 0;
    }
}

- (void)configureCell:(SZNewsFeedTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath isOffScreen:(BOOL)isOffScreen {
    SZPost *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];

    cell.postMessageText.attributedText = object.text;

    if (isOffScreen) {
        return;
    }

    cell.username.text = object.author.name ?: @"";

    cell.timeLabel.text = [_dateFormatter stringFromDate:object.date];;

    cell.likeImage.hidden = object.likesCountValue == 0;
    cell.likesCountLabel.hidden = object.likesCountValue == 0;
    cell.likesCountLabel.text = [NSString stringWithFormat:@"%@", object.likesCount];

    cell.repostImage.hidden = object.repostCountValue == 0;
    cell.repostsCountLabel.hidden = object.repostCountValue == 0;
    cell.repostsCountLabel.text = [NSString stringWithFormat:@"%@", object.repostCount];
    
    [cell.collectionView setTag:indexPath.row];
    [cell.collectionView reloadData];

    [self.imageManager setImageFromUser:object.author to:cell.avatar];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    _fetchedResultsController = [self.localStorage newsFeedFetchedResultsController:self];

    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (_oldPostsLoading) {
        return;
    }
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (_oldPostsLoading) {
        return;
    }
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    if (_oldPostsLoading) {
        return;
    }
    UITableView *tableView = self.tableView;

    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            [self configureCell:(SZNewsFeedTableViewCell*)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath isOffScreen:NO];
            break;

        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (_oldPostsLoading) {
        return;
    }

    [self.tableView endUpdates];
}

#pragma mark Collection View

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    SZPost *object = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:collectionView.tag inSection:0]];
    return object.photos.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SZNewsFeedCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoCollectionCellID" forIndexPath:indexPath];
    SZPost *object = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:collectionView.tag inSection:0]];
    SZPhoto *photo = [object.photos objectAtIndex:indexPath.row];
    [self.imageManager setThumbnailImageFromPhoto:photo to:cell.photoImageView];
    return cell;
}

@end
