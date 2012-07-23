//
//  DMConversationTableViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-7-21.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "DMConversationTableViewController.h"
#import "WBClient.h"
#import "DMConversationTableViewCell.h"
#import "DirectMessage.h"
#import "Conversation.h"
#import "CardViewController.h"
#import "NSUserDefaults+Addition.h"
#import "DMBubbleView.h"
#import "TTTAttributedLabelConfiguer.h"
#import "NSDateAddition.h"

@interface DMConversationTableViewController () {
    long long _nextCursor;
    BOOL _loadingMore;
    NSIndexPath *_targetIndexPath;
}

@end

@implementation DMConversationTableViewController

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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)refresh
{
    _loadingMore = YES;
	[self performSelector:@selector(loadMoreData) withObject:nil afterDelay:0.01];
}

- (void)initialLoadMessageData
{
    _refreshing = YES;
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

- (void)loadMoreData
{
    if (_loading == YES) {
        return;
    }
    _loading = YES;
    
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
			if (_nextCursor == 0) {
				[self clearData];
			}
            
            int prevFetchedCount = self.fetchedResultsController.fetchedObjects.count;
            NSDictionary *result = client.responseJSONObject;
            
            NSArray *dictArray = [result objectForKey:@"direct_messages"];
            for (NSDictionary *dict in dictArray) {
                [DirectMessage insertMessage:dict withConversation:_conversation inManagedObjectContext:self.managedObjectContext];
            }
            
            [self.managedObjectContext processPendingChanges];
            [self.fetchedResultsController performFetch:nil];
            [self adjustMessageSize];
            
            if (_loadingMore) {
                _targetIndexPath = [NSIndexPath indexPathForRow:self.fetchedResultsController.fetchedObjects.count - prevFetchedCount inSection:0];
                [self.tableView scrollToRowAtIndexPath:_targetIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
            } else {
                _targetIndexPath = [NSIndexPath indexPathForRow:self.fetchedResultsController.fetchedObjects.count - 1 inSection:0];
                [self.tableView scrollToRowAtIndexPath:_targetIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }
            [self performSelector:@selector(adjustBackgroundView) withObject:nil afterDelay:0.03];
            
            _nextCursor = [[result objectForKey:@"next_cursor"] intValue];
            _hasMoreViews = NO;
        }
        
        [self refreshEnded];
        [_loadMoreView finishedLoading:_hasMoreViews];
        [_pullView finishedLoading];
        _loading = NO;
        _refreshing = NO;
        _loadingMore = NO;
        
    }];
    
    NSString *maxIDString = nil;
    if (_loadingMore && self.fetchedResultsController.fetchedObjects.count > 0) {
        long long maxID = ((DirectMessage *)[self.fetchedResultsController.fetchedObjects objectAtIndex:0]).messageID.longLongValue;
        maxIDString = [NSString stringWithFormat:@"%lld", maxID - 1];
    }
    
    [client getDirectMessageConversionMessagesOfUser:_conversation.targetUserID
                                             sinceID:nil
                                               maxID:maxIDString
                                      startingAtPage:0
                                               count:20];
}

- (void)receivedNewMessage:(NSDictionary *)dict
{
    DirectMessage *message = [DirectMessage insertMessage:dict withConversation:_conversation inManagedObjectContext:self.managedObjectContext];
    [self adjustSingleMessageSize:message];
    [self.managedObjectContext processPendingChanges];
    [self.fetchedResultsController performFetch:nil];
    [self scrollToBottom];
}

- (void)adjustMessageSize
{
    for (DirectMessage *message in self.fetchedResultsController.fetchedObjects) {
        [self adjustSingleMessageSize:message];
    }
    
    [self.managedObjectContext processPendingChanges];
}

- (void)adjustSingleMessageSize:(DirectMessage *)message
{
    message.text = [TTTAttributedLabelConfiguer replaceEmotionStrings:message.text];
    
    CGSize size = [DMBubbleView sizeForText:message.text fontSize:[NSUserDefaults currentFontSize] leading:[NSUserDefaults currentLeading]];
    
    message.messageHeight = [NSNumber numberWithFloat:size.height];
    message.messageWidth = [NSNumber numberWithFloat:size.width];
}

- (void)scrollToBottom
{
    int count = self.fetchedResultsController.fetchedObjects.count;
    if (count > 0) {
        NSIndexPath *bottomIndexPath = [NSIndexPath indexPathForRow:count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:bottomIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        [self performSelector:@selector(adjustBackgroundView) withObject:nil afterDelay:0.03];
    }
}

#pragma mark - Core Data Table View Method

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *name = [self customCellClassNameForIndex:indexPath];
    
    NSString *CellIdentifier = name ? name : @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        if (name) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:[self customCellClassNameForIndex:(NSIndexPath *)indexPath] owner:self options:nil];
            cell = [nib lastObject];
        }
        else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    [self adjustBackgroundView];
    
    return cell;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
//    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    return;
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationTop];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//    [self.tableView endUpdates];
    [self.tableView reloadData];
    [self performSelector:@selector(adjustBackgroundView) withObject:nil afterDelay:0.05];
}



- (void)configureRequest:(NSFetchRequest *)request
{
    request.entity = [NSEntityDescription entityForName:@"DirectMessage"
                                 inManagedObjectContext:self.managedObjectContext];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
    request.predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", _conversation.messages];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (self.fetchedResultsController.fetchedObjects.count > indexPath.row) {
        DMConversationTableViewCell *messageCell = (DMConversationTableViewCell *)cell;
        
        DirectMessage *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
        DMBubbleViewType type = [message.senderID isEqualToString:self.currentUser.userID] ? DMBubbleViewTypeSent : DMBubbleViewTypeReceived;
        NSString *dateString = [[message createdAt] stringRepresentation];
        
        [messageCell resetWithText:message.text dateString:dateString type:type imageURL:_conversation.targetUserAvatarURL];
        
    } else {
        NSLog(@"Conversation List Core Data Error!");
    }
}

- (NSString *)customCellClassNameForIndex:(NSIndexPath *)indexPath
{
    return @"DMConversationTableViewCell";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;
    if (self.fetchedResultsController.fetchedObjects.count > indexPath.row) {
        DirectMessage *message = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
        height = message.messageHeight.floatValue;
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

- (void)resetLayoutBeforeRotating:(NSNotification *)notification
{
    
}

- (void)resetLayoutAfterRotating:(NSNotification *)notification
{
    
}

@end
