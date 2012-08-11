//
//  ProfileStatusTableViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-5-31.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "ProfileStatusTableViewController.h"
#import "ProfileStatusTableViewCell.h"
#import "WBClient.h"
#import "Status.h"
#import "Comment.h"
#import "User.h"
#import "WaterflowLayoutUnit.h"
#import "NSUserDefaults+Addition.h"
#import "NSNotificationCenter+Addition.h"

@interface ProfileStatusTableViewController () {
    long long _nextCursor;
}

@property (nonatomic, unsafe_unretained) NSInteger searchPage;

@end

@implementation ProfileStatusTableViewController

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
    self.coreDataIdentifier =  self.description;
    _loading = NO;
    self.hasMoreViews = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Data Methods
- (void)clearData
{
    if (_type == StatusTableViewControllerTypeUserStatus) {
        [Status deleteStatusesOfUser:self.user InManagedObjectContext:self.managedObjectContext withOperatingObject:self.coreDataIdentifier];
    } else if(_type == statusTableViewControllerTypeMentionStatus){
        [Status deleteMentionStatusesInManagedObjectContext:self.managedObjectContext];
    } else if(_type == StatusTableViewControllerTypeTopicStatus){
        [Status deleteStatusesWithSearchKey:_searchKey InManagedObjectContext:self.managedObjectContext withOperatingObject:self.coreDataIdentifier];
    }
    [self resetUnreadFollowerCount];
}

- (void)adjustFont
{
    [self resetHeightOfStatuses];
    [super adjustFont];
}

- (void)adjustPictureMode
{
    [self resetHeightOfStatuses];
    [self.tableView reloadData];
    [self performSelector:@selector(adjustBackgroundView) withObject:nil afterDelay:0.1];
}

- (void)resetHeightOfStatuses
{
    for (Status *status in self.fetchedResultsController.fetchedObjects) {
        CGFloat imageHeight = [self randomImageHeight];
        CGFloat cardHeight = [CardViewController heightForStatus:status andImageHeight:imageHeight timeStampEnabled:YES picEnabled:[NSUserDefaults isPictureEnabled]];
        status.cardSizeImageHeight = @(imageHeight);
        status.cardSizeCardHeight = @(cardHeight);
    }
}

- (void)loadMoreData
{
    if (_loading) {
        return;
    }
    _loading = YES;
    [NSNotificationCenter postWillReloadCardCellNotification];
    [NSUserDefaults setReloadingCardCellStatus:YES];
    
    BlockARCWeakSelf weakSelf = self;
    
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            if (weakSelf == nil) {
                return;
            }
            
            NSArray *dictArray = client.responseJSONObject;
            
            if (weakSelf.refreshing) {
                [weakSelf clearData];
            }
            
            for (NSDictionary *dict in dictArray) {
                Status *newStatus = nil;
                newStatus = [Status insertStatus:dict inManagedObjectContext:weakSelf.managedObjectContext withOperatingObject:weakSelf.coreDataIdentifier operatableType:kOperatableTypeNone];
                                
                if (newStatus.cardSizeCardHeight.floatValue == 0.0) {
                    CGFloat imageHeight = [weakSelf randomImageHeight];
                    CGFloat cardHeight = [CardViewController heightForStatus:newStatus andImageHeight:imageHeight timeStampEnabled:YES picEnabled:[NSUserDefaults isPictureEnabled]];
                    newStatus.cardSizeImageHeight = @(imageHeight);
                    newStatus.cardSizeCardHeight = @(cardHeight);
                }
                newStatus.forTableView = @(YES);
                if (weakSelf.type == StatusTableViewControllerTypeUserStatus) {
                    newStatus.author = weakSelf.user;
                } else if(weakSelf.type == statusTableViewControllerTypeMentionStatus) {
                    newStatus.isMentioned = @(YES);
                } else if(weakSelf.type == StatusTableViewControllerTypeTopicStatus){
                    newStatus.searchKey = weakSelf.searchKey;
                }
            }
            
            [weakSelf.managedObjectContext processPendingChanges];
            [weakSelf.fetchedResultsController performFetch:nil];
            
            if (weakSelf.type == StatusTableViewControllerTypeTopicStatus) {
                weakSelf.hasMoreViews = dictArray.count > 10;
            } else {
                weakSelf.hasMoreViews = dictArray.count == 20;
            }
        } else {
            weakSelf.hasMoreViews = NO;
        }
        
        [NSNotificationCenter postDidReloadCardCellNotification];
        [NSUserDefaults setReloadingCardCellStatus:NO];
        [weakSelf refreshEnded];
        [weakSelf adjustBackgroundView];
        [weakSelf finishedLoading];
        [weakSelf scrollViewDidScroll:weakSelf.tableView];
    }];
         
    long long maxID = ((Status *)self.fetchedResultsController.fetchedObjects.lastObject).statusID.longLongValue;
    NSString *maxIDString = self.refreshing ? nil : [NSString stringWithFormat:@"%lld", maxID - 1];
    
    
    if (_type == StatusTableViewControllerTypeUserStatus) {
        [client getUserTimeline:self.user.userID
                        SinceID:nil 
                          maxID:maxIDString
                 startingAtPage:0 
                          count:20 
                        feature:0];
    } else if(_type == statusTableViewControllerTypeMentionStatus) {
        [client getMentionsSinceID:nil
                             maxID:maxIDString
                              page:0
                             count:20];
    } else if(_type == StatusTableViewControllerTypeTopicStatus){
        if ([self.searchKey isEqualToString:kTopicNameHot]) {
            [client getHotStatuses];
        } else {
            NSDate *startDate = self.refreshing ? nil : ((Status *)self.fetchedResultsController.fetchedObjects.lastObject).createdAt;
            [client searchTopic:_searchKey
                     startingAt:startDate
                       clearDup:YES
                          count:20];
        }
    }
}

- (void)refresh
{
    self.refreshing = YES;
    _searchPage = 1;
    [self.fetchedResultsController performFetch:nil];
    [self loadMoreData];
}

- (void)loadMore
{
    [self loadMoreData];
}

- (void)resetUnreadFollowerCount
{
    if (self.type != statusTableViewControllerTypeMentionStatus) {
        return;
    }
    
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client){
        if (!client.hasError) {
            self.currentUser.unreadMentionCount = @0;
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldUpdateUnreadMentionCount object:nil];
        }
    }];
    
    [client resetUnreadCount:kWBClientResetCountTypeMention];
}

- (void)refreshAfterDeletingStatuses:(NSNotification *)notification
{
    NSDictionary *dict = notification.object;
    NSString *coredataIdentifier = [dict objectForKey:kNotificationObjectKeyCoredataIdentifier];
    if ([coredataIdentifier isEqualToString:self.coreDataIdentifier]) {
        NSString *statusID = [dict objectForKey:kNotificationObjectKeyStatusID];
        [Status deleteStatusWithID:statusID inManagedObjectContext:self.managedObjectContext withObject:self.coreDataIdentifier];
        [self.managedObjectContext processPendingChanges];
        [self performSelector:@selector(adjustBackgroundView) withObject:nil afterDelay:0.05];
    }
}

- (CGFloat)randomImageHeight
{
    NSInteger factor = arc4random() % 3;
    CGFloat imageHeight = 0.0;
    
    switch (factor) {
        case 0:
            imageHeight = ImageHeightLow;
            break;
        case 1:
            imageHeight = ImageHeightMid;
            break;
        default:
            imageHeight = ImageHeightHigh;
            break;
    }
    return imageHeight;
}

#pragma mark - Core Data TableView Controller Delegate
- (void)configureRequest:(NSFetchRequest *)request
{
    NSSortDescriptor *sortDescriptor;
	
    sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"statusID" ascending:NO];
    request.sortDescriptors = @[sortDescriptor];
    request.entity = [NSEntityDescription entityForName:@"Status" inManagedObjectContext:self.managedObjectContext];
    
    if (_type == StatusTableViewControllerTypeUserStatus) {
        request.predicate = [NSPredicate predicateWithFormat:@"author == %@ && forTableView == %@ && operatedBy == %@ && currentUserID == %@", self.user, @(YES), self.coreDataIdentifier, self.currentUser.userID];
    } else if (_type == statusTableViewControllerTypeMentionStatus){
        request.predicate = [NSPredicate predicateWithFormat:@"isMentioned == %@ && currentUserID == %@", @(YES), self.currentUser.userID];
    } else if (_type == StatusTableViewControllerTypeTopicStatus){
        request.predicate = [NSPredicate predicateWithFormat:@"searchKey == %@ && operatedBy == %@ && currentUserID == %@", _searchKey, self.coreDataIdentifier, self.currentUser.userID];
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (self.fetchedResultsController.fetchedObjects.count > indexPath.row) {
        ProfileStatusTableViewCell *statusCell = (ProfileStatusTableViewCell *)cell;
        Status *targetStatus = (Status*)[self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
        
        [statusCell setCellHeight:targetStatus.cardSizeCardHeight.floatValue];
        [statusCell.cardViewController configureCardWithStatus:targetStatus
                                                   imageHeight:targetStatus.cardSizeImageHeight.floatValue
                                                     pageIndex:self.pageIndex
                                                   currentUser:self.currentUser
                                            coreDataIdentifier:self.coreDataIdentifier];
    }
}

- (NSString *)customCellClassNameForIndex:(NSIndexPath *)indexPath
{
    return @"ProfileStatusTableViewCell";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.fetchedResultsController.fetchedObjects.count > indexPath.row) {
        Status *targetStatus = (Status*)[self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
        return targetStatus.cardSizeCardHeight.floatValue;
    } else {
        return 0;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    for (ProfileStatusTableViewCell *cell in self.tableView.visibleCells) {
        [cell loadImageAfterScrollingStop];
    }
    if (self.hasMoreViews && self.tableView.contentOffset.y > self.tableView.contentSize.height - self.tableView.frame.size.height) {
        [self loadMoreData];
    }
}



@end
