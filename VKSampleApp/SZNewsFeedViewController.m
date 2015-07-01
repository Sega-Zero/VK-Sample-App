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
#import "SZFeedSimpleTableViewCell.h"

@interface SZNewsFeedViewController ()<UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation SZNewsFeedViewController
{
    NSFetchedResultsController *_fetchedResultsController;
    SZFeedSimpleTableViewCell *_cacheSizeCell;
    BOOL _oldPostsLoading;
    NSDateFormatter *_dateFormatter;
    NSMutableDictionary	*rowHeightCache;
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

    _cacheSizeCell = [self.tableView dequeueReusableCellWithIdentifier:@"SizeCellID"];
    _cacheSizeCell.contentView.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.frame),CGRectGetHeight(self.tableView.frame));
    _cacheSizeCell.hidden = YES;

    rowHeightCache = [NSMutableDictionary dictionary];
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

- (IBAction)collectionViewTap:(id)sender {
    NSIndexPath *indexPathToSelect =[self.tableView indexPathForRowAtPoint:[sender locationOfTouch:0 inView:self.tableView]];
    [self.tableView selectRowAtIndexPath:indexPathToSelect animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self performSegueWithIdentifier:@"showDetailsSegue" sender:self];
}

#pragma mark Storyboard

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showDetailsSegue"] || [segue.identifier isEqualToString:@"showMediaDetailsSegue"]) {
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
    SZPost *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    if (object.photos.count) {
        SZNewsFeedTableViewCell *cell = (SZNewsFeedTableViewCell*) [tableView dequeueReusableCellWithIdentifier:@"FeedMediaCellID"];
        [self configureCell:cell atIndexPath:indexPath];
        return cell;
    }


    SZFeedSimpleTableViewCell *cell = (SZFeedSimpleTableViewCell*) [tableView dequeueReusableCellWithIdentifier:@"FeedCellID" ];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    SZPost *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    NSNumber *cachedHeight = rowHeightCache[object.objectID];

    if (cachedHeight != nil) {
        return [cachedHeight floatValue];
    }

    _cacheSizeCell.postMessageText.attributedText = object.text;

    [_cacheSizeCell.contentView setNeedsLayout];
    [_cacheSizeCell.contentView layoutIfNeeded];

    CGFloat height = [_cacheSizeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;

    if (object.photos.count > 0) {
        height += 150;
    }

    rowHeightCache[object.objectID] = @(height + 1);

    return height + 1/*separator*/;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    SZPost *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    if (object.photos.count > 0) {
        SZNewsFeedTableViewCell *feedCell = (SZNewsFeedTableViewCell *)cell;
        [feedCell.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];

    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SZPost *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];

    BOOL isMediaPost = object.photos.count > 0;
    UILabel *postMessageText   = isMediaPost ? [(SZNewsFeedTableViewCell*)cell postMessageText] : [(SZFeedSimpleTableViewCell*)cell postMessageText];
    UILabel *username          = isMediaPost ? [(SZNewsFeedTableViewCell*)cell username] : [(SZFeedSimpleTableViewCell*)cell username];
    UILabel *timeLabel         = isMediaPost ? [(SZNewsFeedTableViewCell*)cell timeLabel] : [(SZFeedSimpleTableViewCell*)cell timeLabel];
    UILabel *likesCountLabel   = isMediaPost ? [(SZNewsFeedTableViewCell*)cell likesCountLabel] : [(SZFeedSimpleTableViewCell*)cell likesCountLabel];
    UILabel *repostsCountLabel = isMediaPost ? [(SZNewsFeedTableViewCell*)cell repostsCountLabel] : [(SZFeedSimpleTableViewCell*)cell repostsCountLabel];
    UIImageView *likeImage     = isMediaPost ? [(SZNewsFeedTableViewCell*)cell likeImage] : [(SZFeedSimpleTableViewCell*)cell likeImage];
    UIImageView *repostImage   = isMediaPost ? [(SZNewsFeedTableViewCell*)cell repostImage] : [(SZFeedSimpleTableViewCell*)cell repostImage];
    UIImageView *avatar        = isMediaPost ? [(SZNewsFeedTableViewCell*)cell avatar] : [(SZFeedSimpleTableViewCell*)cell avatar];

    postMessageText.attributedText = object.text;

    username.text = @"test user";//object.author.name ?: @"";
    timeLabel.text = [_dateFormatter stringFromDate:object.date];;

    likeImage.hidden = object.likesCountValue == 0;
    likesCountLabel.hidden = object.likesCountValue == 0;
    likesCountLabel.text = [NSString stringWithFormat:@"%@", object.likesCount];

    repostImage.hidden = object.repostCountValue == 0;
    repostsCountLabel.hidden = object.repostCountValue == 0;
    repostsCountLabel.text = [NSString stringWithFormat:@"%@", object.repostCount];

    [self.imageManager setImageFromUser:object.author to:avatar];
    if (isMediaPost) {
        SZNewsFeedTableViewCell *mediaCell = (SZNewsFeedTableViewCell*)cell;
        [mediaCell.collectionView setTag:indexPath.row];
#warning this call leads to table view stuttering for a little, find a way to solve it
        [mediaCell.collectionView reloadData];
    }
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
            [self configureCell:(SZNewsFeedTableViewCell*)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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
