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
#import "User.h"

#import "WaterflowLayoutUnit.h"

@interface ProfileStatusTableViewController () {
    long long _nextCursor;
}

@end


@implementation ProfileStatusTableViewController

@synthesize backgroundViewA = _backgroundViewA;
@synthesize backgroundViewB = _backgroundViewB;

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
    [self refresh];
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma mark - Data Methods
- (void)loadMoreData
{
    if (_loading) {
        return;
    }
    _loading = YES;
    
    WBClient *client = [WBClient client];
    
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            NSDictionary *originalDictArray = client.responseJSONObject;            
            NSArray *dictArray = [originalDictArray objectForKey:@"statuses"];
            for (NSDictionary *dict in dictArray) {
                Status *newStatus = nil;
                newStatus = [Status insertStatus:dict inManagedObjectContext:self.managedObjectContext];
                
                CGFloat imageHeight = [self randomImageHeight];
                CGFloat cardHeight = [CardViewController heightForStatus:newStatus andImageHeight:imageHeight];
                newStatus.cardSizeImageHeight = [NSNumber numberWithFloat:imageHeight];
                newStatus.cardSizeCardHeight = [NSNumber numberWithFloat:cardHeight];
                newStatus.forTableView = [NSNumber numberWithBool:YES];
                [self.user addFriendsStatusesObject:newStatus];
            }
            
            [self.managedObjectContext processPendingChanges];
            [self.fetchedResultsController performFetch:nil];
            
            _hasMoreViews = dictArray.count == 20;
        }
        
        [_loadMoreView finishedLoading:_hasMoreViews];
        [_pullView finishedLoading];
        _loading = NO;
    }];
    
    Status *lastStatus = (Status *)[self.fetchedResultsController.fetchedObjects lastObject];
            
    [client getUserTimeline:self.user.userID 
                    SinceID:nil 
                      maxID:lastStatus.statusID 
             startingAtPage:0 
                      count:20 
                    feature:0];
}

- (void)refresh
{
    if (_loading) {
        return;
    }
    _loading = YES;
    
    WBClient *client = [WBClient client];
    
    [client setCompletionBlock:^(WBClient *client) {
        
        if (!client.hasError) {
            NSDictionary *originalDictArray = client.responseJSONObject;            
            NSArray *dictArray = [originalDictArray objectForKey:@"statuses"];
            for (NSDictionary *dict in dictArray) {
                Status *newStatus = nil;
                newStatus = [Status insertStatus:dict inManagedObjectContext:self.managedObjectContext];
                
                CGFloat imageHeight = [self randomImageHeight];
                CGFloat cardHeight = [CardViewController heightForStatus:newStatus andImageHeight:imageHeight];
                newStatus.cardSizeImageHeight = [NSNumber numberWithFloat:imageHeight];
                newStatus.cardSizeCardHeight = [NSNumber numberWithFloat:cardHeight];
                newStatus.forTableView = [NSNumber numberWithBool:YES];
                [self.user addFriendsStatusesObject:newStatus];
            }
            

            _hasMoreViews = dictArray.count == 20;
            
            [self.managedObjectContext processPendingChanges];
            [self.fetchedResultsController performFetch:nil];
        }
        
        NSLog(@"%d",self.fetchedResultsController.fetchedObjects.count);
        
        [_pullView finishedLoading];
        _loading = NO;
    }];
        
    [client getUserTimeline:self.user.userID 
                    SinceID:nil 
                      maxID:nil
             startingAtPage:0 
                      count:20 
                    feature:0];
}

- (void)loadMore
{
    [self loadMoreData];
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


- (void)adjustBackgroundView
{
    CGFloat top = self.tableView.contentOffset.y;
    CGFloat bottom = top + self.tableView.frame.size.height;
    
    UIView *upperView = nil;
    UIView *lowerView = nil;
    BOOL alignToTop = NO;
    
    if ((alignToTop = [self view:self.backgroundViewA containsPoint:top]) || [self view:self.backgroundViewB containsPoint:bottom]) {
        upperView = self.backgroundViewA;
        lowerView = self.backgroundViewB;
    } else if((alignToTop = [self view:self.backgroundViewB containsPoint:top]) || [self view:self.backgroundViewA containsPoint:bottom]) {
        upperView = self.backgroundViewB;
        lowerView = self.backgroundViewA;
    }
    
    if (upperView && lowerView) {
        if (alignToTop) {
            [lowerView resetOriginY:upperView.frame.origin.y + upperView.frame.size.height];
        } else {
            [upperView resetOriginY:lowerView.frame.origin.y - lowerView.frame.size.height];
        }
    } else {
        [self.backgroundViewA resetOriginY:top];
        [self.backgroundViewB resetOriginY:self.backgroundViewA.frame.origin.y + self.backgroundViewA.frame.size.height];
    }
    
    [self.tableView sendSubviewToBack:self.backgroundViewA];
    [self.tableView sendSubviewToBack:self.backgroundViewB];
    
    [_loadMoreView resetPosition];
}

- (BOOL)view:(UIView *)view containsPoint:(CGFloat)originY
{
    return view.frame.origin.y <= originY && view.frame.origin.y + view.frame.size.height > originY;
}


#pragma mark - Core Data TableView Controller Delegate
- (void)configureRequest:(NSFetchRequest *)request
{
    NSSortDescriptor *sortDescriptor;
	
    sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"statusID" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    request.entity = [NSEntityDescription entityForName:@"Status" inManagedObjectContext:self.managedObjectContext];
    
    request.predicate = [NSPredicate predicateWithFormat:@"author == %@ && forTableView == %@", self.user, [NSNumber numberWithBool:YES]];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ProfileStatusTableViewCell *statusCell = (ProfileStatusTableViewCell *)cell;
    Status *targetStatus = (Status*)[self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    
    [statusCell setCellHeight:targetStatus.cardSizeCardHeight.floatValue];
    
    [statusCell.cardViewController configureCardWithStatus:targetStatus imageHeight:targetStatus.cardSizeImageHeight.floatValue];
}

- (NSString *)customCellClassName
{
    return @"ProfileStatusTableViewCell";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Status *targetStatus = (Status*)[self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];	
	return targetStatus.cardSizeCardHeight.floatValue;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self adjustBackgroundView];
    for (ProfileStatusTableViewCell *cell in self.tableView.visibleCells) {
        [cell loadImageAfterScrollingStop];
    }
    if (_hasMoreViews && self.tableView.contentOffset.y >= self.tableView.contentSize.height - self.tableView.frame.size.height) {
        [self loadMoreData];
    }
}

#pragma mark - Properties
- (BaseLayoutView*)backgroundViewA
{
    if (!_backgroundViewA) {
        _backgroundViewA = [[BaseLayoutView alloc] initWithFrame:CGRectMake(0.0, 0.0, 384.0, 1024.0)];
        _backgroundViewA.autoresizingMask = UIViewAutoresizingNone;
        [self.tableView insertSubview:_backgroundViewA atIndex:0];
    }
    return _backgroundViewA;
}

- (BaseLayoutView*)backgroundViewB
{
    if (!_backgroundViewB) {
        _backgroundViewB = [[BaseLayoutView alloc] initWithFrame:CGRectMake(0.0, 0.0, 384.0, 1024.0)];
        _backgroundViewB.autoresizingMask = UIViewAutoresizingNone;
        [_backgroundViewB resetOriginY:self.backgroundViewA.frame.origin.y + self.backgroundViewA.frame.size.height];
        [self.tableView insertSubview:_backgroundViewB atIndex:0];
    }
    return _backgroundViewB;
}

@end
