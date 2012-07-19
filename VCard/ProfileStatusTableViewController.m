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

@interface ProfileStatusTableViewController () {
    long long _nextCursor;
    NSInteger _searchPage;
}

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
    _coreDataIdentifier =  self.description;
    _loading = NO;
    _hasMoreViews = YES;
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self 
               selector:@selector(resetLayoutAfterRotating:) 
                   name:kNotificationNameOrientationChanged
                 object:nil];
    [center addObserver:self 
               selector:@selector(resetLayoutBeforeRotating:) 
                   name:kNotificationNameOrientationWillChange
                 object:nil];
    [center addObserver:self
               selector:@selector(refreshAfterDeletingStatuses:)
                   name:kNotificationNameShouldDeleteStatus
                 object:nil];
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
        [Status deleteStatusesOfUser:self.user InManagedObjectContext:self.managedObjectContext withOperatingObject:_coreDataIdentifier];
    } else if(_type == statusTableViewControllerTypeMentionStatus){
        [Status deleteMentionStatusesInManagedObjectContext:self.managedObjectContext];
    } else if(_type == StatusTableViewControllerTypeTopicStatus){
        [Status deleteStatusesWithSearchKey:_searchKey InManagedObjectContext:self.managedObjectContext withOperatingObject:_coreDataIdentifier];
    }
}

- (void)loadMoreData
{
    if (_loading) {
        return;
    }
    _loading = YES;
    
    WBClient *client = [WBClient client];
    
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            NSArray *dictArray = client.responseJSONObject;
            
            if (_refreshing) {
                [self clearData];
            }
            
            for (NSDictionary *dict in dictArray) {
                Status *newStatus = nil;
                newStatus = [Status insertStatus:dict inManagedObjectContext:self.managedObjectContext withOperatingObject:_coreDataIdentifier];
                                
                if (newStatus.cardSizeCardHeight.floatValue == 0.0) {
                    CGFloat imageHeight = [self randomImageHeight];
                    CGFloat cardHeight = [CardViewController heightForStatus:newStatus andImageHeight:imageHeight isWaterflowCard:NO];
                    newStatus.cardSizeImageHeight = [NSNumber numberWithFloat:imageHeight];
                    newStatus.cardSizeCardHeight = [NSNumber numberWithFloat:cardHeight];
                }
                newStatus.forTableView = [NSNumber numberWithBool:YES];
                if (_type == StatusTableViewControllerTypeUserStatus) {
                    newStatus.author = self.user;
                } else if(_type == statusTableViewControllerTypeMentionStatus) {
                    newStatus.isMentioned = [NSNumber numberWithBool:YES];
                } else if(_type == StatusTableViewControllerTypeTopicStatus){
                    newStatus.searchKey = _searchKey;
                }
            }
            
            [self.managedObjectContext processPendingChanges];
            [self.fetchedResultsController performFetch:nil];
            
            _hasMoreViews = dictArray.count == 20;
        }
        
        [self refreshEnded];
        [self adjustBackgroundView];
        [_pullView finishedLoading];
        [self scrollViewDidScroll:self.tableView];
        [_loadMoreView finishedLoading:_hasMoreViews];
        _loading = NO;
        _refreshing = NO;
    }];
         
    long long maxID = ((Status *)self.fetchedResultsController.fetchedObjects.lastObject).statusID.longLongValue;
    NSString *maxIDString = _refreshing ? nil : [NSString stringWithFormat:@"%lld", maxID - 1];
    
    
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
        [client searchTopic:_searchKey
             startingAtPage:_searchPage++
                      count:20];
    }
}

- (void)refresh
{
    _refreshing = YES;
    _searchPage = 1;
    [self loadMoreData];
}

- (void)loadMore
{
    [self loadMoreData];
}

- (void)refreshAfterDeletingStatuses:(NSNotification *)notification
{
    NSString *statusID = notification.object;
    [Status deleteStatusWithID:statusID inManagedObjectContext:self.managedObjectContext withObject:_coreDataIdentifier];
    [self.managedObjectContext processPendingChanges];
    [self performSelector:@selector(adjustBackgroundView) withObject:nil afterDelay:0.05];
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
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    request.entity = [NSEntityDescription entityForName:@"Status" inManagedObjectContext:self.managedObjectContext];
    
    if (_type == StatusTableViewControllerTypeUserStatus) {
        request.predicate = [NSPredicate predicateWithFormat:@"author == %@ && forTableView == %@ && operatedBy == %@", self.user, [NSNumber numberWithBool:YES], _coreDataIdentifier];
    } else if (_type == statusTableViewControllerTypeMentionStatus){
        request.predicate = [NSPredicate predicateWithFormat:@"isMentioned == %@", [NSNumber numberWithBool:YES]];
    } else if (_type == StatusTableViewControllerTypeTopicStatus){
        request.predicate = [NSPredicate predicateWithFormat:@"searchKey == %@ && operatedBy == %@", _searchKey, _coreDataIdentifier];
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
                                            coreDataIdentifier:_coreDataIdentifier];
    } else {
        NSLog(@"Core Data TableView Controller Error - profile status config");
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
    if (_hasMoreViews && self.tableView.contentOffset.y > self.tableView.contentSize.height - self.tableView.frame.size.height) {
        [self loadMoreData];
    }
}



@end
