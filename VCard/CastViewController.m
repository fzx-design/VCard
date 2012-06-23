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
#import "PostViewController.h"
#import "UIApplication+Addition.h"
#import "CommentViewController.h"

@interface CastViewController () {
    BOOL _loading;
    NSInteger _nextPage;
}

@property (nonatomic, strong) UIView *coverView;

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
@synthesize showProfileButton = _showProfileButton;

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
    _coverView = [[UIView alloc] initWithFrame:CGRectMake(1024.0, 0.0, 0.0, 0.0)];
    _coverView.backgroundColor = [UIColor blackColor];
    _coverView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
}

- (void)setUpNotification
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(userNameClicked:)
                   name:kNotificationNameUserNameClicked
                 object:nil];
    [center addObserver:self
               selector:@selector(userCellClicked:)
                   name:kNotificationNameUserCellClicked
                 object:nil];
    [center addObserver:self
               selector:@selector(hideWaterflowView)
                   name:kNotificationNameStackViewCoveredWholeScreen
                 object:nil];
    [center addObserver:self
               selector:@selector(showWaterflowView)
                   name:kNotificationNameStackViewDoNotCoverWholeScreen
                 object:nil];
    [center addObserver:self
               selector:@selector(commentButtonClicked:)
                   name:kNotificationCommentButtonClicked
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
    NSDictionary *dictionary = notification.object;
    NSString *screenName = [dictionary valueForKey:kNotificationObjectKeyUserName];
    NSString *indexString = [dictionary valueForKey:kNotificationObjectKeyIndex];
    int index = [indexString intValue];
    
    
    NSString *vcIdentifier = [screenName isEqualToString:self.currentUser.screenName] ? @"SelfProfileViewController" : @"FriendProfileViewController";
    UserProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:vcIdentifier];
    vc.currentUser = self.currentUser;
    vc.screenName = screenName;
    
    //FIXME:
    //Handle errors when screenName is nil
    
    [self stackViewAtIndex:index push:vc withPageType:StackViewPageTypeUser pageDescription:vc.screenName];
}

- (void)userCellClicked:(NSNotification *)notification
{
    NSDictionary *dictionary = notification.object;
    
    User *targetUser = [dictionary valueForKey:kNotificationObjectKeyUser];
    NSString *indexString = [dictionary valueForKey:kNotificationObjectKeyIndex];
    int index = [indexString intValue];
    
    NSString *vcIdentifier = [targetUser.screenName isEqualToString:self.currentUser.screenName] ? @"SelfProfileViewController" : @"FriendProfileViewController";
    
    UserProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:vcIdentifier];
    vc.currentUser = self.currentUser;
    vc.user = targetUser;
    
    [self stackViewAtIndex:index push:vc withPageType:StackViewPageTypeUser pageDescription:vc.user.screenName];
}

- (void)commentButtonClicked:(NSNotification *)notification
{
    NSDictionary *dictionary = notification.object;
    
    Status *status = [dictionary valueForKey:kNotificationObjectKeyStatus];
    NSString *indexString = [dictionary valueForKey:kNotificationObjectKeyIndex];
    int index = indexString.intValue;
    
    CommentViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentViewController"];
    vc.currentUser = self.currentUser;
    vc.status = status;
    
    [self stackViewAtIndex:index push:vc withPageType:StackViewPageTypeStatusComment pageDescription:vc.status.statusID];
}

- (void)hideWaterflowView
{
//    self.waterflowView.alpha = 0.0;
//    _stackViewController.view.backgroundColor = [UIColor clearColor];
}

- (void)showWaterflowView
{
//    self.waterflowView.alpha = 1.0;
    _stackViewController.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
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

#pragma mark Post

- (IBAction)didClickCreateStatusButton:(UIButton *)sender {
    PostViewController *vc = [PostViewController getPostViewControllerViewWithType:PostViewControllerTypeNewStatus
                                                                          delegate:self
                                                                           weiboID:nil
                                                                    weiboOwnerName:nil];
    [vc showViewFromRect:sender.frame];
}

#pragma mark Stack View
- (IBAction)groupButtonClicked:(id)sender
{
//    [self createStackView];
}

- (IBAction)showProfileButtonClicked:(id)sender
{
    UserProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SelfProfileViewController"];
    vc.currentUser = self.currentUser;
    vc.screenName = self.currentUser.screenName;
    
    [self stackViewAtIndex:0 push:vc withPageType:StackViewPageTypeUser pageDescription:vc.screenName];
}

- (void)stackViewAtIndex:(int)index
                    push:(StackViewPageController *)vc
            withPageType:(StackViewPageType)pageType
         pageDescription:(NSString *)pageDescription;
{
    BOOL stackViewExists = _stackViewController != nil;
    if (!stackViewExists) {
        _stackViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"StackViewController"];
        
        [_stackViewController.view resetOrigin:CGPointMake(0.0, 43.0)];
        [_stackViewController.view resetSize:self.waterflowView.frame.size];
        _stackViewController.currentUser = self.currentUser;
        _stackViewController.delegate = self;
        
        [self.view insertSubview:_coverView belowSubview:_navigationView];
        
        [self.view insertSubview:_stackViewController.view aboveSubview:_coverView];
        
        [UIView animateWithDuration:0.3 animations:^{
            _stackViewController.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        }];
    }
//        [_stackViewController addViewController:vc replacingOtherView:stackViewExists];
//    } else {
        [_stackViewController insertStackPage:vc atIndex:index withPageType:pageType pageDescription:pageDescription];
//    }
    
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
                newStatus.forCastView = [NSNumber numberWithBool:YES];
                
                CGFloat imageHeight = [self randomImageHeight];
                CGFloat cardHeight = [CardViewController heightForStatus:newStatus andImageHeight:imageHeight];
                newStatus.cardSizeImageHeight = [NSNumber numberWithFloat:imageHeight];
                newStatus.cardSizeCardHeight = [NSNumber numberWithFloat:cardHeight];
                
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
                newStatus.forCastView = [NSNumber numberWithBool:YES];
                CGFloat imageHeight = [self randomImageHeight];
                CGFloat cardHeight = [CardViewController heightForStatus:newStatus andImageHeight:imageHeight];
                newStatus.cardSizeImageHeight = [NSNumber numberWithFloat:imageHeight];
                newStatus.cardSizeCardHeight = [NSNumber numberWithFloat:cardHeight];
                [self.currentUser addFriendsStatusesObject:newStatus];
            }
            
            [self.managedObjectContext processPendingChanges];
            [self.fetchedResultsController performFetch:nil];
            
            int count = self.fetchedResultsController.fetchedObjects.count - 1;
            for (int i = dictArray.count - 1;i < count ; i++) {
                [Status deleteObject:(Status *)[self.fetchedResultsController.fetchedObjects lastObject] inManagedObjectContext:self.managedObjectContext];
                [self.managedObjectContext processPendingChanges];
                [self.fetchedResultsController performFetch:nil];
            }
            
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
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.waterflowView scrollViewDidScroll:self.waterflowView];
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

#pragma mark - CoreDataTableViewController methods

- (void)configureRequest:(NSFetchRequest *)request
{
    NSSortDescriptor *sortDescriptor;
	
    sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"statusID" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    request.entity = [NSEntityDescription entityForName:@"Status" inManagedObjectContext:self.managedObjectContext];
 
    request.predicate = [NSPredicate predicateWithFormat:@"isFriendsStatusOf == %@", self.currentUser];
                  
}

- (NSString *)customCellClassNameForIndex:(NSIndexPath *)indexPath
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
        
        [((WaterflowCardCell *)cell).cardViewController configureCardWithStatus:targetStatus
                                                                    imageHeight:layoutUnit.imageHeight
                                                                      pageIndex:0];
        
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
    
}

#pragma mark - Stack View Controller Delegate
- (void)clearStack
{
    [_coverView removeFromSuperview];
    [_coverView resetOriginX:1024.0];
    [UIView animateWithDuration:0.3 animations:^{
        _stackViewController.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [_stackViewController.view removeFromSuperview];
        _stackViewController = nil;
    }];
}

- (void)stackViewScrolledWithOffset:(CGFloat)scrollViewOffsetX width:(CGFloat)scrollViewWidth
{
    CGFloat screenWidth = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? 768.0 : 1024.0;
    CGFloat screenHeight = screenWidth == 768.0 ? 1024.0 : 768.0;
    CGFloat originX = screenWidth - scrollViewOffsetX;
    CGFloat width = scrollViewWidth > screenWidth ? screenWidth : scrollViewWidth;

    [_coverView setFrame:CGRectMake(originX, 0.0, width, screenHeight)];
}

#pragma mark - PostViewController Delegate

- (void)postViewController:(PostViewController *)vc willPostMessage:(NSString *)message {
    [vc dismissViewUpwards];
}

- (void)postViewController:(PostViewController *)vc didPostMessage:(NSString *)message {
    
}

- (void)postViewController:(PostViewController *)vc didFailPostMessage:(NSString *)message {
    
}

- (void)postViewController:(PostViewController *)vc willDropMessage:(NSString *)message {
    [vc dismissViewToRect:self.createStatusButton.frame];
}

@end
