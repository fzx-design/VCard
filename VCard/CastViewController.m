//
//  CastViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-4-18.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "CastViewController.h"
#import "UserProfileViewController.h"
#import "UIImageViewAddition.h"
#import "UIView+Resize.h"
#import "ResourceList.h"
#import "WBClient.h"
#import "Status.h"
#import "User.h"

#import "WaterflowCardCell.h"
#import "WaterflowDividerCell.h"

@interface CastViewController () {
    BOOL _loading;
    NSInteger _nextPage;
}

@end

@implementation CastViewController

@synthesize navigationView = _navigationView;
@synthesize waterflowView = _waterflowView;
@synthesize refreshIndicatorView = _refreshIndicatorView;
@synthesize profileImageView = _profileImageView;
@synthesize searchButton = _searchButton;
@synthesize groupButton = _groupButton;
@synthesize createStatusButton = _createStatusButton;
@synthesize refreshButton = _refreshButton;

#pragma mark - LifeCycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        [self refresh];
        [self setUpNotification];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.profileImageView loadImageFromURL:self.currentUser.profileImageURL completion:nil];
    
    [self.fetchedResultsController performFetch:nil];
    [self setUpWaterflowView];
    [self setUpVariables];
}

- (void)setUpVariables
{
    _loading = NO;
    _nextPage = 1;
    _refreshIndicatorView.hidden = YES;
}

- (void)setUpNotification
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(userNameClicked:)
                   name:kNotificationNameUserNameClicked
                 object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark - Initializing Methods
- (void)setUpWaterflowView
{
    _pullView = [[PullToRefreshView alloc] initWithScrollView:(UIScrollView *)self.waterflowView];
    [_pullView setDelegate:self];
    [self.waterflowView addSubview:_pullView];
    
    self.waterflowView.flowdatasource = self;
    self.waterflowView.flowdelegate = self;
    
    [self.waterflowView refresh];
}

- (void)userNameClicked:(NSNotification *)notification
{
    NSString *screenName = notification.object;
    NSString *vcIdentifier = [screenName isEqualToString:self.currentUser.screenName] ? @"SelfProfileViewController" : @"FriendProfileViewController";
    UserProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:vcIdentifier];
    vc.screenName = screenName;
    
    [self stackViewPush:vc];
}

#pragma mark - IBActions
#pragma mark Refresh
- (IBAction)refreshButtonClicked:(id)sender
{
    _refreshIndicatorView.hidden = NO;
    [_refreshIndicatorView startLoadingAnimation];
    
    [_pullView setState:PullToRefreshViewStateLoading];
    
    self.refreshButton.userInteractionEnabled = NO;
    [self refresh];
}

- (void)refreshEnded
{
    [UIView animateWithDuration:0.3 animations:^{
        _refreshIndicatorView.alpha = 0.0;
    } completion:^(BOOL finished) {
        _refreshIndicatorView.hidden = YES;
        _refreshIndicatorView.alpha = 1.0;
        self.refreshButton.userInteractionEnabled = YES;
    }];
}

#pragma mark Stack View
- (IBAction)groupButtonClicked:(id)sender
{
//    [self createStackView];
}

- (void)stackViewPush:(UIViewController *)vc
{
    if (!_stackViewController) {
        _stackViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"StackViewController"];
        [_stackViewController.view resetOrigin:CGPointMake(0.0, 43.0)];
        [_stackViewController.view resetSize:self.waterflowView.frame.size];
        _stackViewController.currentUser = self.currentUser;
        _stackViewController.delegate = self;
        [self.view insertSubview:_stackViewController.view belowSubview:_navigationView];
        [UIView animateWithDuration:0.3 animations:^{
            _stackViewController.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        }];
    }
    
    [_stackViewController addViewController:vc replacingOtherView:NO];
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
            NSArray *dictArray = client.responseJSONObject;
            for (NSDictionary *dict in dictArray) {
                Status *newStatus = nil;
                newStatus = [Status insertStatus:dict inManagedObjectContext:self.managedObjectContext];
                [self.currentUser addFriendsStatusesObject:newStatus];  
            }
            
            [self.managedObjectContext processPendingChanges];
            [self.fetchedResultsController performFetch:nil];
            [self.waterflowView reloadData];
        }
        
        _loading = NO;
    }];
    
    Status *lastStatus = (Status *)[self.fetchedResultsController.fetchedObjects lastObject];
    
    [client getFriendsTimelineSinceID:nil 
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
        [self refreshEnded];
        
        if (!client.hasError) {
            NSArray *dictArray = client.responseJSONObject;
            for (NSDictionary *dict in dictArray) {
                Status *newStatus = nil;
                newStatus = [Status insertStatus:dict inManagedObjectContext:self.managedObjectContext];
                [self.currentUser addFriendsStatusesObject:newStatus];
            }
            
            [self.managedObjectContext processPendingChanges];
            [self.fetchedResultsController performFetch:nil];
            
            [self.waterflowView refresh];
            
        }
        
        [_pullView finishedLoading];
        _loading = NO;
    }];
    
    [client getFriendsTimelineSinceID:nil 
                                maxID:nil 
                       startingAtPage:0
                                count:20 
                              feature:0];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                duration:(NSTimeInterval)duration 
{
    [self.waterflowView adjustViewsForOrientation:toInterfaceOrientation];
    [_pullView resetLayoutToOrientation:toInterfaceOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.waterflowView scrollViewDidScroll:self.waterflowView];
}

#pragma mark - CoreDataTableViewController methods

- (void)configureRequest:(NSFetchRequest *)request
{
    NSSortDescriptor *sortDescriptor;
	
    sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"statusID" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    request.entity = [NSEntityDescription entityForName:@"Status" inManagedObjectContext:self.managedObjectContext];
 
    request.predicate = [NSPredicate predicateWithFormat:@"isFriendsStatusOf == %@", self.currentUser];
                  
}

- (NSString *)customCellClassName
{
    return @"CardTableViewCell";
}


#pragma mark - PullToRefreshViewDelegate
- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view
{
    [self refresh];
}

#pragma mark - WaterflowDataSource

- (WaterflowCell*)flowView:(WaterflowView *)flowView_ cellForLayoutUnit:(WaterflowLayoutUnit *)layoutUnit
{
    static NSString *CellIdentifier;
    if (layoutUnit.unitType == UnitTypeCard) {
        CellIdentifier = kReuseIdentifierCardCell;
    } else if(layoutUnit.unitType == UnitTypeDivider){
        CellIdentifier = kReuseIdentifierDividerCell;
    } else {
        CellIdentifier = kReuseIdentifierEmptyCell;
    }
    
	WaterflowCell *cell = [flowView_ dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if(cell == nil) {
        if (layoutUnit.unitType == UnitTypeCard) {
            cell = [[WaterflowCardCell alloc] initWithReuseIdentifier:CellIdentifier currentUser:self.currentUser];
            ((WaterflowCardCell *)cell).cardViewController.currentUser = self.currentUser;
        } else if(layoutUnit.unitType == UnitTypeDivider) {
            cell = [[WaterflowDividerCell alloc] initWithReuseIdentifier:CellIdentifier currentUser:self.currentUser];
        } else {
            cell = [[WaterflowCell alloc] initWithReuseIdentifier:CellIdentifier currentUser:self.currentUser];
        }
	}
    
    if (layoutUnit.unitType == UnitTypeCard) {
        
        Status *targetStatus = (Status*)[self.fetchedResultsController.fetchedObjects objectAtIndex:layoutUnit.dataIndex];
        [cell setCellHeight:[layoutUnit unitHeight]];
        
        [((WaterflowCardCell *)cell).cardViewController configureCardWithStatus:targetStatus imageHeight:layoutUnit.imageHeight];
        
    } else if(layoutUnit.unitType == UnitTypeDivider) {
        Status *targetStatus = (Status*)[self.fetchedResultsController.fetchedObjects objectAtIndex:layoutUnit.dataIndex];
        [((WaterflowDividerCell *)cell).dividerViewController updateTimeInformation:targetStatus.createdAt];
    }
    
	return cell;
}

- (void)flowViewLoadMoreViews
{
    [self loadMoreData];
}

- (int)numberOfObjectsInSection
{
    return self.fetchedResultsController.fetchedObjects.count;
}

- (CGFloat)heightForObjectAtIndex:(int)index_ withImageHeight:(NSInteger)imageHeight_
{
    Status *status = (Status *)[self.fetchedResultsController.fetchedObjects objectAtIndex:index_];
    return [CardViewController heightForStatus:status andImageHeight:imageHeight_];
}

#pragma mark-
#pragma mark- WaterflowDelegate

- (void)flowView:(WaterflowView *)flowView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"did select at %@",indexPath);
}

#pragma mark - Stack View Controller Delegate
- (void)clearStack
{
    [UIView animateWithDuration:0.3 animations:^{
        _stackViewController.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [_stackViewController.view removeFromSuperview];
        _stackViewController = nil;
    }];
    
}

@end
