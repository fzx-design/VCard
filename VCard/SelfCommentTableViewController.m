//
//  SelfCommentTableViewController.m
//  VCard
//
//  Created by Gabriel Yeah on 12-6-24.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "SelfCommentTableViewController.h"
#import "SelfCommentTableViewCell.h"
#import "WBClient.h"
#import "CardViewController.h"

@interface SelfCommentTableViewController () {
    int _toMeNextPage;
    int _byMeNextPage;
}

@end

@implementation SelfCommentTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _coreDataIdentifier = self.description;
    _loading = NO;
    _toMeNextPage = 1;
    _byMeNextPage = 1;
    _hasMoreViews = YES;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(refreshAfterDeletingComment:)
                   name:kNotificationNameShouldDeleteComment
                 object:nil];
    [center addObserver:self
               selector:@selector(refreshAfterPostingComment)
                   name:kNotificationNameShouldRefreshAfterPost
                 object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshAfterDeletingComment:(NSNotification *)notification
{
    NSString *commentID = notification.object;
    [Comment deleteCommentWithID:commentID inManagedObjectContext:self.managedObjectContext withObject:_coreDataIdentifier];
    [self.managedObjectContext processPendingChanges];
    
    [self performSelector:@selector(adjustBackgroundView) withObject:nil afterDelay:0.05];
}

- (void)refreshAfterPostingComment
{
    if (self.dataSource == CommentsTableViewDataSourceCommentsByMe) {
        [self refresh];
    }
}

#pragma mark - Data Operation

- (void)refresh
{
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
    if (self.dataSource == CommentsTableViewDataSourceCommentsByMe) {
		[Comment deleteCommentsByMeInManagedObjectContext:self.managedObjectContext];
    } else if(self.dataSource == CommentsTableViewDataSourceCommentsToMe){
		[Comment deleteCommentsToMeInManagedObjectContext:self.managedObjectContext];
    } else if(self.dataSource == CommentsTableViewDataSourceCommentsMentioningMe) {
        [Comment deleteCommentsMentioningMeInManagedObjectContext:self.managedObjectContext];
    }
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
            
            if (_refreshing) {
				[self clearData];
			}

            
            if (_dataSource == CommentsTableViewDataSourceCommentsToMe) {
				for (NSDictionary *dict in dictArray) {
					Comment *comment = [Comment insertCommentToMe:dict inManagedObjectContext:self.managedObjectContext];
                    comment.commentHeight = [NSNumber numberWithFloat:[CardViewController heightForTextContent:comment.text]];
				}
				[self.managedObjectContext processPendingChanges];
				
				if (_commentsToMeFetchedResultsController) {
					_commentsToMeFetchedResultsController = nil;
				}
				
				_commentsToMeFetchedResultsController = self.fetchedResultsController;
				_toMeNextPage++;
                
			} else if(_dataSource == CommentsTableViewDataSourceCommentsByMe) {
				for (NSDictionary *dict in dictArray) {
					Comment *comment = [Comment insertCommentByMe:dict inManagedObjectContext:self.managedObjectContext];
                    comment.commentHeight = [NSNumber numberWithFloat:[CardViewController heightForTextContent:comment.text]];
				}
				[self.managedObjectContext processPendingChanges];
				
				if (_commentsByMeFetchedResultsController) {
					_commentsByMeFetchedResultsController = nil;
				}
				
				_commentsByMeFetchedResultsController = self.fetchedResultsController;
				_byMeNextPage++;
			} else if (_dataSource == CommentsTableViewDataSourceCommentsMentioningMe) {
                for (NSDictionary *dict in dictArray) {
					Comment *comment = [Comment insertCommentMentioningMe:dict inManagedObjectContext:self.managedObjectContext];
                    comment.commentHeight = [NSNumber numberWithFloat:[CardViewController heightForTextContent:comment.text]];
				}
				[self.managedObjectContext processPendingChanges];
            }
            
            [self.managedObjectContext processPendingChanges];
            [self.fetchedResultsController performFetch:nil];
            
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
    
    long long maxID = ((Comment *)self.fetchedResultsController.fetchedObjects.lastObject).commentID.longLongValue - 1;
    maxID = maxID < 0 ? 0 : maxID;
    NSString *maxIDString = _refreshing ? nil : [NSString stringWithFormat:@"%lld", maxID];
    
    if (self.dataSource == CommentsTableViewDataSourceCommentsByMe) {
		[client getCommentsByMeSinceID:nil
                                 maxID:maxIDString
                                  page:0
                                 count:20];
    }
    else if(self.dataSource == CommentsTableViewDataSourceCommentsToMe){
        [client getCommentsToMeSinceID:nil
                                 maxID:maxIDString
                                  page:0
                                 count:20];
    } else if (self.dataSource == CommentsTableViewDataSourceCommentsMentioningMe) {
        [client getCommentsMentioningMeSinceID:nil
                                         maxID:maxIDString
                                          page:1
                                         count:20];
    }
}

- (void)switchToToMe
{
	self.dataSource = CommentsTableViewDataSourceCommentsToMe;
	
	if (_commentsToMeFetchedResultsController) {
		self.fetchedResultsController = _commentsToMeFetchedResultsController;
	} else {
		self.fetchedResultsController = nil;
		[self refresh];
	}
	
	[self.tableView reloadData];
    [self performSelector:@selector(adjustBackgroundView) withObject:nil afterDelay:0.001];
}

- (void)switchToByMe
{
	self.dataSource = CommentsTableViewDataSourceCommentsByMe;
	
	if (_commentsByMeFetchedResultsController) {
		self.fetchedResultsController = _commentsByMeFetchedResultsController;
	} else {
		self.fetchedResultsController = nil;
		[self refresh];
	}
	
	[self.tableView reloadData];
    [self performSelector:@selector(adjustBackgroundView) withObject:nil afterDelay:0.001];
}


#pragma mark - Core Data Table View Method

- (void)configureRequest:(NSFetchRequest *)request
{
    request.entity = [NSEntityDescription entityForName:@"Comment"
                                 inManagedObjectContext:self.managedObjectContext];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"commentID" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    if (self.dataSource == CommentsTableViewDataSourceCommentsToMe) {
		request.predicate = [NSPredicate predicateWithFormat:@"toMe == %@", [NSNumber numberWithBool:YES]];
	} else if(self.dataSource == CommentsTableViewDataSourceCommentsByMe) {
		request.predicate = [NSPredicate predicateWithFormat:@"byMe == %@", [NSNumber numberWithBool:YES]];
	} else if(self.dataSource == CommentsTableViewDataSourceCommentsMentioningMe){
        request.predicate = [NSPredicate predicateWithFormat:@"mentioningMe == %@", [NSNumber numberWithBool:YES]]; 
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    SelfCommentTableViewCell *commentCell = (SelfCommentTableViewCell *)cell;
    Comment *comment = (Comment *)[self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    [commentCell resetOriginX:11.0];
    [commentCell resetSize:CGSizeMake(362.0, comment.commentHeight.floatValue)];
    [commentCell.baseCardBackgroundView resetSize:CGSizeMake(362.0, comment.commentHeight.floatValue)];
    [commentCell configureCellWithComment:comment];
    commentCell.pageIndex = self.pageIndex;
    commentCell.delegate = self;
    
}

- (NSString *)customCellClassNameForIndex:(NSIndexPath *)indexPath
{
    return @"SelfCommentTableViewCell";
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
    CGFloat height = indexPath.row == self.fetchedResultsController.fetchedObjects.count - 1 ? 0.0 : 10.0;
    height += ((Comment *)[self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row]).commentHeight.floatValue;
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
