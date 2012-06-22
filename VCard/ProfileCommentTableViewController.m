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
	_nextCursor = -1;
    _page = 1;
	[self performSelector:@selector(loadMoreData) withObject:nil afterDelay:0.01];
}

- (void)loadMore
{
    [self loadMoreData];
}

- (void)clearData
{
    //TODO: 
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
            
            for (NSDictionary *dict in dictArray) {
                Comment *comment = [Comment insertComment:dict inManagedObjectContext:self.managedObjectContext];
                comment.commentHeight = [NSNumber numberWithFloat:[CardViewController heightForComment:comment]];
                [self.status addCommentsObject:comment];
                if (_filterByAuthor) {
                    comment.authorFollowedByMe = [NSNumber numberWithBool:YES];
                }
            }
            
            [self.managedObjectContext processPendingChanges];
            [self.fetchedResultsController performFetch:nil];
            
            if (_sourceChanged) {
                _sourceChanged = NO;
                [self configureRequest:self.fetchedResultsController.fetchRequest];
                [self.fetchedResultsController performFetch:nil];
                [self.tableView reloadData];
            }
            
            _nextCursor = [[client.responseJSONObject objectForKey:@"next_cursor"] intValue];
            _hasMoreViews = _nextCursor != 0;
        }
        
        [self performSelector:@selector(adjustBackgroundView) withObject:nil afterDelay:0.01];
        [_loadMoreView finishedLoading:_hasMoreViews];
        [_pullView finishedLoading];
        _loading = NO;
        
    }];
    
    [client getCommentOfStaus:self.status.statusID
                       cursor:_page++
                        count:20
                 authorFilter:_filterByAuthor];
}

#pragma mark - Core Data Table View Method

- (void)configureRequest:(NSFetchRequest *)request
{
    request.entity = [NSEntityDescription entityForName:@"Comment"
                                 inManagedObjectContext:self.managedObjectContext];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateDate" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    if (_filterByAuthor) {
        request.predicate = [NSPredicate predicateWithFormat:@"SELF IN %@ && authorFollowedByMe == %@", self.status.comments, [NSNumber numberWithBool:YES]];
    } else {
        request.predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", self.status.comments];
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        ProfileCommentStatusTableCell *statusCell = (ProfileCommentStatusTableCell *)cell;
        Status *targetStatus = self.status;
        
        [statusCell setCellHeight:targetStatus.cardSizeCardHeight.floatValue];
        [statusCell.cardViewController configureCardWithStatus:targetStatus imageHeight:targetStatus.cardSizeImageHeight.floatValue];
        
        BOOL hasContent = self.fetchedResultsController.fetchedObjects.count > 0;
        [statusCell resetDividerViewFilterByAuthor:_filterByAuthor
                                        hasContent:hasContent];
    
    } else {
        ProfileCommentTableViewCell *commentCell = (ProfileCommentTableViewCell *)cell;
        Comment *comment = (Comment *)self.fetchedResultsController.fetchedObjects[indexPath.row - 1];
        [commentCell resetOriginX:11.0];
        [commentCell resetSize:CGSizeMake(362.0, comment.commentHeight.floatValue)];
        [commentCell.baseCardBackgroundView resetSize:CGSizeMake(362.0, comment.commentHeight.floatValue)];
        BOOL isFirstComment = indexPath.row == 1;
        BOOL isLastComment = indexPath.row == self.fetchedResultsController.fetchedObjects.count;
        [commentCell configureCellWithComment:comment
                                isLastComment:isLastComment
                               isFirstComment:isFirstComment];
    }
}

- (NSString *)customCellClassNameForIndex:(NSIndexPath *)indexPath
{
    return indexPath.row == 0 ? @"ProfileCommentStatusTableCell" : @"ProfileCommentTableViewCell";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *usr = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:usr, kNotificationObjectKeyUser, [NSString stringWithFormat:@"%d", _stackPageIndex], kNotificationObjectKeyIndex, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameUserCellClicked object:dictionary];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;
    if (indexPath.row == 0) {
        height = self.status.cardSizeCardHeight.floatValue + 36;
    } else {
        Comment *comment = (Comment *)self.fetchedResultsController.fetchedObjects[indexPath.row - 1];
        height = comment.commentHeight.floatValue + 24.0;
    }
    
	return height;
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
