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

@interface DMConversationTableViewController () {
    long long _nextCursor;
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
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)refresh
{
	_nextCursor = 0;
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
            
            NSDictionary *result = client.responseJSONObject;
			
            NSArray *dictArray = [result objectForKey:@"direct_messages"];
            for (NSDictionary *dict in dictArray) {
                [DirectMessage insertMessage:dict withConversation:_conversation inManagedObjectContext:self.managedObjectContext];
            }
            
            [self.managedObjectContext processPendingChanges];
            [self.fetchedResultsController performFetch:nil];
            
            _nextCursor = [[result objectForKey:@"next_cursor"] intValue];
            _hasMoreViews = _nextCursor != 0;
        }
        
        [self adjustBackgroundView];
        [self refreshEnded];
        [_loadMoreView finishedLoading:_hasMoreViews];
        [_pullView finishedLoading];
        _loading = NO;
        
    }];
    
    long long maxID = ((DirectMessage *)self.fetchedResultsController.fetchedObjects.lastObject).messageID.longLongValue;
    NSString *maxIDString = _refreshing ? nil : [NSString stringWithFormat:@"%lld", maxID - 1];
    
    [client getDirectMessageConversionMessagesOfUser:_conversation.targetUserID
                                             sinceID:nil
                                               maxID:maxIDString
                                      startingAtPage:0
                                               count:20];
}

#pragma mark - Core Data Table View Method

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
        DMConversationTableViewCell *listCell = (DMConversationTableViewCell *)cell;
        DirectMessage *conversation = [self.fetchedResultsController objectAtIndexPath:indexPath];
        listCell.textLabel.text = conversation.text;
        
        if (indexPath.row % 2 == 0) {
            listCell.contentView.backgroundColor = [UIColor clearColor];
        } else {
            listCell.contentView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.05];
        }
    } else {
        NSLog(@"Conversation List Core Data Error!");
    }
}

- (NSString *)customCellClassNameForIndex:(NSIndexPath *)indexPath
{
    return @"DMConversationTableViewCell";
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
