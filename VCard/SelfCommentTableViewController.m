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
#import "TTTAttributedLabelConfiguer.h"

@interface SelfCommentTableViewController ()

@property (nonatomic, unsafe_unretained) int nextCursor;
@property (nonatomic, unsafe_unretained) int nextPage;
@property (nonatomic, unsafe_unretained) BOOL resetFonts;

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
    self.coreDataIdentifier = self.description;
    _loading = NO;
    _nextPage = 1;
    self.hasMoreViews = YES;
    _resetFonts = NO;
}

- (void)refreshAfterDeletingComment:(NSNotification *)notification
{
    NSString *commentID = notification.object;
    [Comment deleteCommentWithID:commentID inManagedObjectContext:self.managedObjectContext withObject:self.coreDataIdentifier];
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
- (void)initialLoad
{
    [self.fetchedResultsController performFetch:nil];
    if (self.fetchedResultsController.fetchedObjects.count > 0) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
        [self performSelector:@selector(adjustBackgroundView) withObject:nil afterDelay:0.05];
    } else {
        [self refresh];
    }
}

- (void)refresh
{
	_nextCursor = -1;
    self.refreshing = YES;
	[self performSelector:@selector(loadMoreData) withObject:nil afterDelay:0.05];
}

- (void)loadMore
{
    [self loadMoreData];
}

- (void)adjustFont
{
    for (Comment *comment in self.fetchedResultsController.fetchedObjects) {
        comment.commentHeight = @([CardViewController heightForTextContent:comment.text]);
    }

    _resetFonts = YES;
    [super adjustFont];
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
    [self resetUnreadCommentCount];
}

- (void)loadMoreData
{
    if (_loading == YES) {
        return;
    }
    _loading = YES;
    
    BlockARCWeakSelf weakSelf = self;
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            if (weakSelf == nil) {
                return;
            }
            
            NSDictionary *result = client.responseJSONObject;
            if ([result isKindOfClass:[NSDictionary class]]) {
                NSArray *dictArray = [result objectForKey:@"comments"];
                
                if (weakSelf.refreshing) {
                    [weakSelf clearData];
                }
                
                if (weakSelf.dataSource == CommentsTableViewDataSourceCommentsToMe) {
                    for (NSDictionary *dict in dictArray) {
                        Comment *comment = [Comment insertCommentToMe:dict inManagedObjectContext:weakSelf.managedObjectContext];
                        comment.text = [TTTAttributedLabelConfiguer replaceEmotionStrings:comment.text];
                        comment.commentHeight = @([CardViewController heightForTextContent:comment.text]);
                    }
                    [weakSelf.managedObjectContext processPendingChanges];
                    
                } else if(weakSelf.dataSource == CommentsTableViewDataSourceCommentsByMe) {
                    for (NSDictionary *dict in dictArray) {
                        Comment *comment = [Comment insertCommentByMe:dict inManagedObjectContext:weakSelf.managedObjectContext];
                        comment.text = [TTTAttributedLabelConfiguer replaceEmotionStrings:comment.text];
                        comment.commentHeight = @([CardViewController heightForTextContent:comment.text]);
                    }
                    [weakSelf.managedObjectContext processPendingChanges];
                    
                } else if (weakSelf.dataSource == CommentsTableViewDataSourceCommentsMentioningMe) {
                    for (NSDictionary *dict in dictArray) {
                        Comment *comment = [Comment insertCommentMentioningMe:dict inManagedObjectContext:weakSelf.managedObjectContext];
                        comment.text = [TTTAttributedLabelConfiguer replaceEmotionStrings:comment.text];
                        comment.commentHeight = @([CardViewController heightForTextContent:comment.text]);
                    }
                    [weakSelf.managedObjectContext processPendingChanges];
                }
                
                [weakSelf.managedObjectContext processPendingChanges];
                [weakSelf.fetchedResultsController performFetch:nil];
                
                weakSelf.nextCursor = [[result objectForKey:@"next_cursor"] intValue];
                weakSelf.hasMoreViews = weakSelf.nextCursor != 0;
                weakSelf.nextPage++;
            }            
        }
        
        [weakSelf adjustBackgroundView];
        [weakSelf refreshEnded];
        [weakSelf finishedLoading];
        
    }];
    
    long long maxID = ((Comment *)self.fetchedResultsController.fetchedObjects.lastObject).commentID.longLongValue - 1;
    maxID = maxID < 0 ? 0 : maxID;
    NSString *maxIDString = self.refreshing ? nil : [NSString stringWithFormat:@"%lld", maxID];
    
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

- (void)resetFontsWhenSourceChanged
{
    if (_resetFonts) {
        _resetFonts = NO;
        for (Comment *comment in self.fetchedResultsController.fetchedObjects) {
            comment.commentHeight = @([CardViewController heightForTextContent:comment.text]);
        }
    }
}

- (void)resetUnreadCommentCount
{
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client){
        if (!client.hasError) {
            if (self.dataSource == CommentsTableViewDataSourceCommentsToMe) {
                self.currentUser.unreadCommentCount = @0;
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldUpdateUnreadCommentCount object:nil];
            } else if (self.dataSource == CommentsTableViewDataSourceCommentsMentioningMe) {
                self.currentUser.unreadMentionComment = @0;
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldUpdateUnreadMentionCommentCount object:nil];
            }
        }
    }];
    
    NSString *type = @"";
    if (self.dataSource == CommentsTableViewDataSourceCommentsToMe) {
        type = kWBClientResetCountTypeComment;
    } else if (self.dataSource == CommentsTableViewDataSourceCommentsMentioningMe) {
        type = kWBClientResetCountTypeMetionComment;
    }
    [client resetUnreadCount:type];
}

#pragma mark - Core Data Table View Method

- (void)configureRequest:(NSFetchRequest *)request
{
    request.entity = [NSEntityDescription entityForName:@"Comment"
                                 inManagedObjectContext:self.managedObjectContext];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"commentID" ascending:NO];
    request.sortDescriptors = @[sortDescriptor];
    if (self.dataSource == CommentsTableViewDataSourceCommentsToMe) {
		request.predicate = [NSPredicate predicateWithFormat:@"toMe == %@ && currentUserID == %@", @(YES), self.currentUser.userID];
	} else if(self.dataSource == CommentsTableViewDataSourceCommentsByMe) {
		request.predicate = [NSPredicate predicateWithFormat:@"byMe == %@ && currentUserID == %@", @(YES), self.currentUser.userID];
	} else if(self.dataSource == CommentsTableViewDataSourceCommentsMentioningMe){
        request.predicate = [NSPredicate predicateWithFormat:@"mentioningMe == %@ && currentUserID == %@", @(YES), self.currentUser.userID]; 
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (self.fetchedResultsController.fetchedObjects.count > indexPath.row) {
        SelfCommentTableViewCell *commentCell = (SelfCommentTableViewCell *)cell;
        Comment *comment = (Comment *)[self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
        [commentCell resetOriginX:11.0];
        [commentCell resetSize:CGSizeMake(362.0, comment.commentHeight.floatValue)];
        [commentCell.baseCardBackgroundView resetSize:CGSizeMake(362.0, comment.commentHeight.floatValue)];
        [commentCell configureCellWithComment:comment];
        commentCell.pageIndex = self.pageIndex;
        commentCell.delegate = self;
    } else {
        NSLog(@"Core Data TableView Controller Error - Self comment config");
    }
    
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
    if (self.fetchedResultsController.fetchedObjects.count > indexPath.row) {
        height += ((Comment *)[self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row]).commentHeight.floatValue;
    } else {
        NSLog(@"Core Data TableView Controller Error - Self comment height");
    }
	return height;
}

#pragma mark - UIScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    
    if (self.hasMoreViews && self.tableView.contentOffset.y >= self.tableView.contentSize.height - self.tableView.frame.size.height) {
        [self loadMoreData];
    }
}

@end
