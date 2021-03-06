//
//  DMListTableViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-7-21.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "DMListTableViewController.h"
#import "DMListTableViewCell.h"
#import "Conversation.h"
#import "DirectMessage.h"
#import "WBClient.h"
#import "NSUserDefaults+Addition.h"
#import "UIView+Addition.h"

@interface DMListTableViewController ()

@property (nonatomic, unsafe_unretained) long long nextCursor;
@property (nonatomic, unsafe_unretained) BOOL shouldReload;
@property (nonatomic, unsafe_unretained) int selectedRow;

@end

@implementation DMListTableViewController

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
    _shouldReload = NO;
    _selectedRow = -1;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)refresh
{
	_nextCursor = 0;
	[self loadMoreData];
}

- (void)loadMore
{
    [self loadMoreData];
}

- (void)clearData
{
     
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
            NSDictionary *result = client.responseJSONObject;
            NSArray *dictArray = [result objectForKey:@"user_list"];
            for (NSDictionary *dict in dictArray) {
                [Conversation insertConversation:dict toCurrentUser:self.currentUser.userID inManagedObjectContext:self.managedObjectContext];
            }
            
            if (_nextCursor == 0) {
				[self clearData];
                [self resetUnreadMessageCount];
			}
            
            [self.managedObjectContext processPendingChanges];
            [self.fetchedResultsController performFetch:nil];
            
            _nextCursor = [[result objectForKey:@"next_cursor"] intValue];
            self.hasMoreViews = _nextCursor != 0;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldSaveContext object:nil];
        }
        
        [self performSelector:@selector(adjustBackgroundView) withObject:nil afterDelay:0.05];
        [self refreshEnded];
        [self finishedLoading];
        
    }];
    
    [client getDirectMessageConversationListWithCursor:_nextCursor count:20];
}

- (void)resetUnreadMessageCount
{
    [NSUserDefaults setFetchedMessages:YES];
    WBClient *client = [WBClient client];
    
    [client setCompletionBlock:^(WBClient *client){
        if (!client.hasError) {
            self.currentUser.unreadMessageCount = @0;
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldUpdateUnreadMessageCount object:nil];
        }
    }];
    [client resetUnreadCount:kWBClientResetCountTypeMessage];
}

#pragma mark - Core Data Table View Method

- (void)configureRequest:(NSFetchRequest *)request
{
    request.entity = [NSEntityDescription entityForName:@"Conversation"
                                 inManagedObjectContext:self.managedObjectContext];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateDate" ascending:NO];
    request.predicate = [NSPredicate predicateWithFormat:@"currentUserID == %@", self.currentUser.userID];
    request.sortDescriptors = @[sortDescriptor];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (self.fetchedResultsController.fetchedObjects.count > indexPath.row) {
        DMListTableViewCell *listCell = (DMListTableViewCell *)cell;
        Conversation *conversation = [self.fetchedResultsController objectAtIndexPath:indexPath];
        listCell.screenNameLabel.text = conversation.targetUser.screenName;
        listCell.infoLabel.text = conversation.latestMessageText;
        listCell.hasNewIndicator.hidden = !conversation.hasNew.boolValue || indexPath.row == _selectedRow;
        
        [listCell.avatarImageView loadImageFromURL:conversation.targetUser.profileImageURL
                                        completion:NULL];
        [listCell.avatarImageView setVerifiedType:[conversation.targetUser verifiedTypeOfUser]];
        
        if (indexPath.row % 2 == 0) {
            listCell.contentView.backgroundColor = [UIColor clearColor];
        } else {
            listCell.contentView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.05];
        }
    }
    [self adjustBackgroundView];
}

- (NSString *)customCellClassNameForIndex:(NSIndexPath *)indexPath
{
    return @"DMListTableViewCell";
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationTop];
            _shouldReload = YES;
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            _shouldReload = YES;
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            _shouldReload = YES;
            break;
    }
    [self adjustBackgroundView];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
    if ((self.isBeingDisplayed && self.shouldReload) || self.firstLoad) {
        [self.tableView reloadData];
        self.shouldReload = NO;
        self.firstLoad = NO;
    }
    [self performSelector:@selector(adjustBackgroundView) withObject:nil afterDelay:0.10];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedRow = indexPath.row;
    
    Conversation *conversation = [self.fetchedResultsController objectAtIndexPath:indexPath];
    conversation.hasNew = @(NO);
    
    DMListTableViewCell *cell = (DMListTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    cell.hasNewIndicator.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldShowConversation object:@{kNotificationObjectKeyConversation: conversation,
                 kNotificationObjectKeyIndex: [NSString stringWithFormat:@"%i", self.pageIndex],
         kNotificationObjectKeyShouldRefresh: @(NO)}];
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
