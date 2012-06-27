//
//  ProfileCommentTableViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-5-31.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "ProfileCommentTableViewController.h"
#import "ProfileCommentTableViewCell.h"
#import "ProfileCommentStatusTableCell.h"
#import "WBClient.h"
#import "Comment.h"
#import "User.h"
#import "WaterflowLayoutUnit.h"

@implementation ProfileCommentTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.autoresizingMask = UIViewAutoresizingNone;
    _coreDataIdentifier = self.description;
    _loading = NO;
    _hasMoreViews = YES;
    _sourceChanged = NO;
    _filterByAuthor = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Data Operation

- (void)refresh
{
    _page = 1;
	_nextCursor = -1;
    _refreshing = YES;
	[self performSelector:@selector(loadMoreData) withObject:nil afterDelay:0.01];
}

- (void)loadMore
{
    [self loadMoreData];
}

- (void)clearData
{
    if (_type == CommentTableViewControllerTypeComment) {
        [Comment deleteCommentsOfStatus:self.status
                   ManagedObjectContext:self.managedObjectContext
                    withOperatingObject:_coreDataIdentifier];
    } else {
        [Status deleteRepostsOfStatus:self.status
                   ManagedObjectContext:self.managedObjectContext
                    withOperatingObject:_coreDataIdentifier];
    }
}

- (void)changeSource
{
    _filterByAuthor = !_filterByAuthor;
    _sourceChanged = YES;
    [self refresh];
}

- (void)loadMoreData
{
    if (_loading == YES) {
        return;
    }
    _loading = YES;
    
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            
            if (_sourceChanged || _refreshing) {
                _sourceChanged = NO;
                [self clearData];
            }
            
            if (_type == CommentTableViewControllerTypeComment) {
                NSArray *dictArray = [client.responseJSONObject objectForKey:@"comments"];
                for (NSDictionary *dict in dictArray) {
                    Comment *comment = [Comment insertComment:dict inManagedObjectContext:self.managedObjectContext withOperatingObject:_coreDataIdentifier];
                    comment.commentHeight = [NSNumber numberWithFloat:[CardViewController heightForTextContent:comment.text]];
                    [self.status addCommentsObject:comment];
                }
            } else {
                NSArray *dictArray = [client.responseJSONObject objectForKey:@"reposts"];
                for (NSDictionary *dict in dictArray) {
                    Status *status = [Status insertStatus:dict inManagedObjectContext:self.managedObjectContext withOperatingObject:_coreDataIdentifier];
                    status.cardSizeCardHeight = [NSNumber numberWithFloat:[CardViewController heightForTextContent:status.text]];
                    [_status addRepostedByObject:status];
                }
            }
            
            [self.managedObjectContext processPendingChanges];
            [self.fetchedResultsController performFetch:nil];
            
            [self updateHeaderViewInfo];
            [self updateVisibleCells];
            
            _nextCursor = [[client.responseJSONObject objectForKey:@"next_cursor"] intValue];
            _hasMoreViews = _nextCursor != 0;
            
        }
        
        [self refreshEnded];
        [self adjustBackgroundView];
        [_loadMoreView finishedLoading:_hasMoreViews];
        [_pullView finishedLoading];
        _loading = NO;
        _refreshing = NO;
        
    }];
    
    
    if (_type == CommentTableViewControllerTypeComment) {
        long long maxID = ((Comment *)self.fetchedResultsController.fetchedObjects.lastObject).commentID.longLongValue;
        NSString *maxIDString = _refreshing ? nil : [NSString stringWithFormat:@"%lld", maxID - 1];
        [client getCommentOfStatus:self.status.statusID
                            maxID:maxIDString
                            count:20
                     authorFilter:_filterByAuthor];
    } else {
        long long maxID = ((Status *)self.fetchedResultsController.fetchedObjects.lastObject).statusID.longLongValue;
        NSString *maxIDString = _refreshing ? nil : [NSString stringWithFormat:@"%lld", maxID - 1];
        [client getRepostOfStatus:self.status.statusID
                            maxID:maxIDString
                            count:20
                     authorFilter:_filterByAuthor];
    }
}

#pragma mark - Core Data Table View Method

- (void)configureRequest:(NSFetchRequest *)request
{
    if (_type == CommentTableViewControllerTypeComment) {
        request.entity = [NSEntityDescription entityForName:@"Comment"
                                     inManagedObjectContext:self.managedObjectContext];
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"commentID" ascending:NO];
        request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        request.predicate = [NSPredicate predicateWithFormat:@"SELF IN %@ && operatedBy == %@", self.status.comments, _coreDataIdentifier];
    } else {
        request.entity = [NSEntityDescription entityForName:@"Status"
                                     inManagedObjectContext:self.managedObjectContext];
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"statusID" ascending:NO];
        request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        request.predicate = [NSPredicate predicateWithFormat:@"SELF IN %@ && operatedBy == %@", self.status.repostedBy, _coreDataIdentifier];
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ProfileCommentTableViewCell *commentCell = (ProfileCommentTableViewCell *)cell;
    if (_type == CommentTableViewControllerTypeComment) {
        Comment *comment = (Comment *)[self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
        [commentCell resetOriginX:11.0];
        [commentCell resetSize:CGSizeMake(362.0, comment.commentHeight.floatValue)];
        [commentCell.baseCardBackgroundView resetSize:CGSizeMake(362.0, comment.commentHeight.floatValue)];
        BOOL isFirstComment = indexPath.row == 0;
        BOOL isLastComment = indexPath.row == self.fetchedResultsController.fetchedObjects.count - 1;
        [commentCell configureCellWithComment:comment
                                isLastComment:isLastComment
                               isFirstComment:isFirstComment];
        commentCell.pageIndex = self.pageIndex;
    } else {
        Status *repost = (Status *)[self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
        [commentCell resetSize:CGSizeMake(362.0, repost.cardSizeCardHeight.floatValue)];
        [commentCell.baseCardBackgroundView resetSize:CGSizeMake(362.0, repost.cardSizeCardHeight.floatValue)];
        [commentCell configureCellWithStatus:repost];
        commentCell.pageIndex = self.pageIndex;
    }

}

- (NSString *)customCellClassNameForIndex:(NSIndexPath *)indexPath
{
    return @"ProfileCommentTableViewCell";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;
    if (_type == CommentTableViewControllerTypeComment) {
        height = ((Comment *)[self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row]).commentHeight.floatValue;
    } else  {
        height = ((Status *)[self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row]).cardSizeCardHeight.floatValue;
    }
	return height;
}

#pragma mark - Adjust table view layout

- (void)setUpHeaderView
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ProfileCommentStatusTableCell"];
    _headerViewCell = (ProfileCommentStatusTableCell *)cell;
    
    Status *targetStatus = self.status;
    
    CGFloat height = [CardViewController heightForStatus:self.status andImageHeight:ImageHeightHigh];
    
    [_headerViewCell setCellHeight:height];
    [_headerViewCell.cardViewController configureCardWithStatus:targetStatus
                                                    imageHeight:ImageHeightHigh
                                                      pageIndex:self.pageIndex
                                                    currentUser:self.currentUser];
    [_headerViewCell loadImageAfterScrollingStop];
    _headerViewCell.typeString = _type == CommentTableViewControllerTypeComment ? @"评论" : @"转发";
    _headerViewCell.pageIndex = self.pageIndex;
    
    [self updateHeaderViewInfo];
    [self.tableView setTableHeaderView:_headerViewCell];
    [_loadMoreView resetPosition];
}

- (void)updateHeaderViewInfo
{
    int actualCount = self.fetchedResultsController.fetchedObjects.count;
    int fetchedCount = 0.0;
    if (_type == CommentTableViewControllerTypeComment) {
        fetchedCount =  _filterByAuthor ? 0.0 : self.status.commentsCount.intValue;
    } else {
        fetchedCount = _filterByAuthor ? 0.0 : self.status.repostsCount.intValue;
    }
    int displayCount = fetchedCount > actualCount ? fetchedCount : actualCount;
    [_headerViewCell resetDividerViewWithCommentCount:displayCount];
}

- (void)updateVisibleCells
{
    if (_type == CommentTableViewControllerTypeComment) {
        for (ProfileCommentTableViewCell *cell in self.tableView.visibleCells) {
            BOOL isLast = [self.tableView indexPathForCell:cell].row == self.fetchedResultsController.fetchedObjects.count - 1;
            [cell updateThreadStatus:isLast];
        }
    }
}

#pragma mark - UIScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    
    if (_hasMoreViews && self.tableView.contentOffset.y >= self.tableView.contentSize.height - self.tableView.frame.size.height) {
        [self loadMoreData];
    }
}

@end
