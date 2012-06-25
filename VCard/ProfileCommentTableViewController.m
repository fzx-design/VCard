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
    [Comment deleteCommentsOfStatus:self.status ManagedObjectContext:self.managedObjectContext withOperatingObject:self.description];
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
            NSArray *dictArray = [client.responseJSONObject objectForKey:@"comments"];
            
            if (_sourceChanged || _refreshing) {
                _sourceChanged = NO;
                [self clearData];
            }
            
            for (NSDictionary *dict in dictArray) {
                Comment *comment = [Comment insertComment:dict inManagedObjectContext:self.managedObjectContext withOperatingObject:self.description];
                comment.commentHeight = [NSNumber numberWithFloat:[CardViewController heightForComment:comment]];
                [self.status addCommentsObject:comment];
            }
            
            [self.managedObjectContext processPendingChanges];
            [self.fetchedResultsController performFetch:nil];
            
            [self updateHeaderViewInfo];
            [self updateVisibleCells];
            
            _nextCursor = [[client.responseJSONObject objectForKey:@"next_cursor"] intValue];
            _hasMoreViews = _nextCursor != 0;
            
        }
        
        [self adjustBackgroundView];
        [_loadMoreView finishedLoading:_hasMoreViews];
        [_pullView finishedLoading];
        _loading = NO;
        _refreshing = NO;
        
    }];
    
    NSString *maxID = _refreshing ? nil : ((Comment *)self.fetchedResultsController.fetchedObjects.lastObject).commentID;
    
    [client getCommentOfStaus:self.status.statusID
                        maxID:maxID
                        count:20
                 authorFilter:_filterByAuthor];
}

#pragma mark - Core Data Table View Method

- (void)configureRequest:(NSFetchRequest *)request
{
    request.entity = [NSEntityDescription entityForName:@"Comment"
                                 inManagedObjectContext:self.managedObjectContext];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"commentID" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    request.predicate = [NSPredicate predicateWithFormat:@"SELF IN %@ && operatedBy == %@", self.status.comments, self.description];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ProfileCommentTableViewCell *commentCell = (ProfileCommentTableViewCell *)cell;
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
    Comment *comment = (Comment *)[self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
	return comment.commentHeight.floatValue;
}

#pragma mark - Adjust table view layout

- (void)setUpHeaderView
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ProfileCommentStatusTableCell"];
    _headerViewCell = (ProfileCommentStatusTableCell *)cell;
    
    Status *targetStatus = self.status;
    
    [_headerViewCell setCellHeight:targetStatus.cardSizeCardHeight.floatValue];
    [_headerViewCell.cardViewController configureCardWithStatus:targetStatus
                                                    imageHeight:targetStatus.cardSizeImageHeight.floatValue
                                                      pageIndex:self.pageIndex];
    [_headerViewCell loadImageAfterScrollingStop];
    _headerViewCell.pageIndex = self.pageIndex;
    
    int cellHeight = self.status.cardSizeCardHeight.intValue + 36.0;
    [_headerViewCell resetHeight:cellHeight];
    [self updateHeaderViewInfo];
    
    [self.tableView setTableHeaderView:_headerViewCell];
}

- (void)updateHeaderViewInfo
{
    int actualCount = self.fetchedResultsController.fetchedObjects.count;
    int fetchedCount = _filterByAuthor ? 0 : self.status.commentsCount.intValue;
    int displayCount = fetchedCount > actualCount ? fetchedCount : actualCount;
    [_headerViewCell resetDividerViewWithCommentCount:displayCount];
}

- (void)updateVisibleCells
{
    for (ProfileCommentTableViewCell *cell in self.tableView.visibleCells) {
        BOOL isLast = [self.tableView indexPathForCell:cell].row == self.fetchedResultsController.fetchedObjects.count - 1;
        [cell updateThreadStatus:isLast];
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
