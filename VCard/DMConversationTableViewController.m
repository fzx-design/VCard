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
#import "NSDate+Addition.h"

@interface DMConversationTableViewController ()

@property (nonatomic, unsafe_unretained) long long      nextCursor;
@property (nonatomic, unsafe_unretained) BOOL           loadingMore;
@property (nonatomic, unsafe_unretained) NSString       *lastMessageID;
@property (nonatomic, unsafe_unretained) NSIndexPath    *targetIndexPath;

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
    _loadMoreView.hidden = YES;
    self.tableView.alpha = 0.0;
//    UIEdgeInsets inset = self.tableView.contentInset;
//    inset.bottom = 20.0;
//    self.tableView.contentInset = inset;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)refresh
{
    _loadingMore = YES;
	[self loadMoreData];
}

- (void)initialLoadMessageData
{
    self.refreshing = YES;
	[self loadMoreData];
}

- (void)loadMore
{
    [self loadMoreData];
}

- (void)clearData
{
    [DirectMessage deleteMessagesOfConversion:self.conversation inManagedObjectContext:self.managedObjectContext];
}

- (void)loadMoreData
{
    if (_loading == YES) {
        return;
    }
    _loading = YES;
    
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError && self.isBeingDisplayed) {
			if (self.refreshing) {
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
            
            if (self.fetchedResultsController.fetchedObjects.count > 0) {
                if (_loadingMore) {
                    if (prevFetchedCount == 0) {
                        prevFetchedCount = 1;
                    }
                    _targetIndexPath = [NSIndexPath indexPathForRow:self.fetchedResultsController.fetchedObjects.count - prevFetchedCount inSection:0];
                    [self.tableView scrollToRowAtIndexPath:_targetIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                } else {
                    [self scrollToBottom:NO];
                }
                int count = self.fetchedResultsController.fetchedObjects.count - 1;
                DirectMessage *message = [self.fetchedResultsController.fetchedObjects objectAtIndex:count];
                _lastMessageID = message.messageID;
                self.conversation.empty = @(NO);
            } else {
                self.tableView.alpha = 1.0;
            }
            
            [self performSelector:@selector(adjustBackgroundView) withObject:nil afterDelay:0.03];
            
            _nextCursor = [[result objectForKey:@"next_cursor"] intValue];
            self.hasMoreViews = NO;
        } else {
            [self.fetchedResultsController performFetch:nil];
            [self adjustMessageSize];
            if (!_loadingMore) {
                [self scrollToBottom:NO];
            }
        }
        
        [self refreshEnded];
        [self finishedLoading];
        
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
    [self scrollToBottom:YES];
    [self finishedLoading];
    _lastMessageID = message.messageID;
}

- (void)getUnreadMessageThroughTimer
{
    if (self.currentUser.unreadMessageCount.intValue == 0 && self.isBeingDisplayed) {
        return;
    }
    
    [self getUnreadMessage];
}

- (void)getUnreadMessage
{
    if (_loading == YES) {
        return;
    }
    _loading = YES;
    
    BlockARCWeakSelf weakSelf = self;
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError && weakSelf.isBeingDisplayed) {
            NSDictionary *result = client.responseJSONObject;
            NSArray *dictArray = [result objectForKey:@"direct_messages"];
            for (NSDictionary *dict in dictArray) {
                [DirectMessage insertMessage:dict withConversation:weakSelf.conversation inManagedObjectContext:weakSelf.managedObjectContext];
            }
            
            [weakSelf.managedObjectContext processPendingChanges];
            [weakSelf.fetchedResultsController performFetch:nil];
            [weakSelf adjustMessageSize];
            [weakSelf checkNewMessage];
            
            weakSelf.nextCursor = [[result objectForKey:@"next_cursor"] intValue];
            weakSelf.hasMoreViews = NO;
        }
        
        [weakSelf refreshEnded];
        [weakSelf finishedLoading];
        
    }];
    
    NSString *sinceIDString = nil;
    if (self.fetchedResultsController.fetchedObjects.count > 0) {
        int count = self.fetchedResultsController.fetchedObjects.count - 1;
        long long maxID = ((DirectMessage *)[self.fetchedResultsController.fetchedObjects objectAtIndex:count]).messageID.longLongValue;
        sinceIDString = [NSString stringWithFormat:@"%lld", maxID];
    }
    
    [client getDirectMessageConversionMessagesOfUser:_conversation.targetUserID
                                             sinceID:sinceIDString
                                               maxID:nil
                                      startingAtPage:0
                                               count:100];
}



- (void)checkNewMessage
{
    if (!self.isBeingDisplayed) {
        return;
    }
    
    if (self.fetchedResultsController.fetchedObjects.count > 0) {
        int count = self.fetchedResultsController.fetchedObjects.count - 1;
        DirectMessage *message = [self.fetchedResultsController.fetchedObjects objectAtIndex:count];
        
        if (![self.lastMessageID isEqualToString:message.messageID]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.fetchedResultsController.fetchedObjects.count - 1 inSection:0];
            self.lastMessageID = message.messageID;
            [self.tableView reloadData];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            [self resetUnreadMessageCount];
            [[SoundManager sharedManager] playNewMessageSound];
        }
        self.conversation.latestMessageText = message.text;
    }
    [self performSelector:@selector(adjustBackgroundView) withObject:nil afterDelay:0.03];
}

- (void)resetUnreadMessageCount
{
    WBClient *client = [WBClient client];
    
    [client setCompletionBlock:^(WBClient *client){
        if (!client.hasError) {
            self.currentUser.unreadMessageCount = @0;
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldUpdateUnreadMessageCount object:nil];
        }
    }];
    [client resetUnreadCount:kWBClientResetCountTypeMessage];
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
    
    CGSize size = [DMBubbleView sizeForText:message.text];
    
    message.messageHeight = @(size.height);
    message.messageWidth = @(size.width);
}

- (void)scrollToBottom:(BOOL)animated
{
    if (self.firstLoad) {
        self.firstLoad = NO;
        [UIView animateWithDuration:0.2 animations:^{
            self.tableView.alpha = 1.0;
        }];
    }

    CGFloat originY = self.tableView.contentSize.height - self.tableView.frame.size.height;
    if (originY < 0) {
        originY = 0;
    }
    
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.contentOffset = CGPointMake(0.0, originY);
        }];
    } else {
        self.tableView.contentOffset = CGPointMake(0.0, originY);
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

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    //Intended to be left blank
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    //Intended to be left blank
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (self.isBeingDisplayed) {
        [self.tableView reloadData];
        [self performSelector:@selector(adjustBackgroundView) withObject:nil afterDelay:0.05];
    }
}


- (void)configureRequest:(NSFetchRequest *)request
{
    request.entity = [NSEntityDescription entityForName:@"DirectMessage"
                                 inManagedObjectContext:self.managedObjectContext];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
    request.predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", _conversation.messages];
    request.sortDescriptors = @[sortDescriptor];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (self.fetchedResultsController.fetchedObjects.count > indexPath.row) {
        DMConversationTableViewCell *messageCell = (DMConversationTableViewCell *)cell;
        
        DirectMessage *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
        DMBubbleViewType type = [message.senderID isEqualToString:self.currentUser.userID] ? DMBubbleViewTypeSent : DMBubbleViewTypeReceived;
        NSString *dateString = [[message createdAt] stringRepresentation];
        
        messageCell.index = indexPath.row;
        [messageCell resetWithText:message.text dateString:dateString type:type imageURL:_conversation.targetUserAvatarURL];
        messageCell.delegate = self;
        messageCell.pageIndex = self.pageIndex;
        [messageCell setUp];
        
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

#pragma mark - DMCell delegate
- (void)shouldDeleteMessageAtIndex:(int)index
{
    if (index >= self.fetchedResultsController.fetchedObjects.count) {
        return;
    }
    
    DirectMessage *message = [self.fetchedResultsController.fetchedObjects objectAtIndex:index];
    
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            [self.managedObjectContext deleteObject:message];
            [self.managedObjectContext processPendingChanges];
        }
    }];
    [client deleteDirectMessage:message.messageID];
}

#pragma mark - UIScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    if (self.hasMoreViews && self.tableView.contentOffset.y >= self.tableView.contentSize.height - self.tableView.frame.size.height) {
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
