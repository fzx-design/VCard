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
    _toMeNextPage = 1;
    _byMeNextPage = 1;
    _hasMoreViews = YES;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    }
    else {
		[Comment deleteCommentsToMeInManagedObjectContext:self.managedObjectContext];
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
            
            if (_toMeNextPage == 1 && _dataSource == CommentsTableViewDataSourceCommentsToMe) {
				[self clearData];
			} 
			if (_byMeNextPage == 1 && _dataSource == CommentsTableViewDataSourceCommentsByMe) {
				[self clearData];
			}
            
            
            if (_dataSource == CommentsTableViewDataSourceCommentsToMe) {
				for (NSDictionary *dict in dictArray) {
					Comment *comment = [Comment insertCommentToMe:dict inManagedObjectContext:self.managedObjectContext];
                    comment.commentHeight = [NSNumber numberWithFloat:[CardViewController heightForComment:comment]];
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
                    comment.commentHeight = [NSNumber numberWithFloat:[CardViewController heightForComment:comment]];
				}
				[self.managedObjectContext processPendingChanges];
				
				if (_commentsByMeFetchedResultsController) {
					_commentsByMeFetchedResultsController = nil;
				}
				
				_commentsByMeFetchedResultsController = self.fetchedResultsController;
				_byMeNextPage++;
			}
            
            [self.managedObjectContext processPendingChanges];
            [self.fetchedResultsController performFetch:nil];
            
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
    
    if (self.dataSource == CommentsTableViewDataSourceCommentsByMe) {
		[client getCommentsByMeSinceID:nil
                                 maxID:maxID
                                  page:_byMeNextPage
                                 count:20];
    }
    else if(self.dataSource == CommentsTableViewDataSourceCommentsToMe){
        [client getCommentsToMeSinceID:nil
                                 maxID:maxID
                                  page:_toMeNextPage
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
	}
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    SelfCommentTableViewCell *commentCell = (SelfCommentTableViewCell *)cell;
    Comment *comment = (Comment *)self.fetchedResultsController.fetchedObjects[indexPath.row];
    [commentCell resetOriginX:11.0];
    [commentCell resetSize:CGSizeMake(362.0, comment.commentHeight.floatValue)];
    [commentCell.baseCardBackgroundView resetSize:CGSizeMake(362.0, comment.commentHeight.floatValue)];
    [commentCell configureCellWithComment:comment];
    commentCell.pageIndex = self.pageIndex;
    
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
    Comment *comment = (Comment *)self.fetchedResultsController.fetchedObjects[indexPath.row];    
	return comment.commentHeight.floatValue;
}


@end
