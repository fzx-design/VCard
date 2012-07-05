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
#import "Comment.h"
#import "User.h"
#import "WaterflowCardCell.h"
#import "WaterflowDividerCell.h"
#import "PostViewController.h"
#import "UIApplication+Addition.h"
#import "CommentViewController.h"
#import "SelfCommentViewController.h"
#import "SelfProfileViewController.h"
#import "TopicViewController.h"

@interface CastViewController () {
    BOOL _loading;
    NSInteger _nextPage;
    BOOL _hasMoreViews;
    BOOL _refreshing;
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
        [self setUpNotification];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.profileImageView loadImageFromURL:self.currentUser.profileImageURL completion:nil];
    _coreDataIdentifier = kCoreDataIdentifierDefault;
//    [self.fetchedResultsController performFetch:nil];
//    [self setUpWaterflowView];
    [self setUpVariables];
}

- (void)setUpVariables
{
    _loading = NO;
    _nextPage = 1;
    _refreshIndicatorView.hidden = YES;
    _refreshing = YES;
    _coverView = [[UIView alloc] initWithFrame:CGRectMake(1024.0, 0.0, 0.0, 0.0)];
    _coverView.backgroundColor = [UIColor blackColor];
    _coverView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
}

- (void)setUpNotification
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(showUserByName:)
                   name:kNotificationNameShouldShowUserByName
                 object:nil];
    [center addObserver:self
               selector:@selector(showUserByCell:)
                   name:kNotificationNameShouldShowUserByCell
                 object:nil];
    [center addObserver:self
               selector:@selector(showCommentList:)
                   name:kNotificationNameShouldShowCommentList
                 object:nil];
    [center addObserver:self
               selector:@selector(showRepostList:)
                   name:kNotificationNameShouldShowRepostList
                 object:nil];
    [center addObserver:self
               selector:@selector(showSelfCommentList:)
                   name:kNotificationNameShouldShowSelfCommentList
                 object:nil];
    [center addObserver:self
               selector:@selector(showSelfMentionList:)
                   name:kNotificationNameShouldShowSelfMentionList
                 object:nil];
    [center addObserver:self
               selector:@selector(showTopic:)
                   name:kNotificationNameShouldShowTopic
                 object:nil];
    [center addObserver:self
               selector:@selector(refreshEnded)
                   name:kNotificationNameRefreshEnded
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
               selector:@selector(refreshAfterDeletingStatuses:)
                   name:kNotificationNameShouldDeleteStatus
                 object:nil];
    [center addObserver:self
               selector:@selector(refreshAfterDeletingComment:)
                   name:kNotificationNameShouldDeleteComment
                 object:nil];
    
    [center addObserver:self
               selector:@selector(updateUnreadStatusCount)
                   name:kNotificationNameShouldUpdateUnreadStatusCount
                 object:nil];
    [center addObserver:self
               selector:@selector(updateUnreadCommentCount)
                   name:kNotificationNameShouldUpdateUnreadCommentCount
                 object:nil];
    [center addObserver:self
               selector:@selector(updateUnreadMentionCount)
                   name:kNotificationNameShouldUpdateUnreadMentionCount
                 object:nil];
    [center addObserver:self
               selector:@selector(updateUnreadFollowCount)
                   name:kNotificationNameShouldUpdateUnreadFollowCount
                 object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark - Initializing Methods
- (void)initialLoad
{
    [self performSelector:@selector(setUpWaterflowView) withObject:nil afterDelay:0.001];
}

- (void)setUpWaterflowView
{
    self.waterflowView.flowdatasource = self;
    self.waterflowView.flowdelegate = self;
    [self.waterflowView refresh];
    
    _pullView = [[PullToRefreshView alloc] initWithScrollView:(UIScrollView *)self.waterflowView];
    _pullView.delegate = self;
    _pullView.shouldAutoRotate = YES;
    _loadMoreView = [[LoadMoreView alloc] initWithScrollView:(UIScrollView *)self.waterflowView];
    _loadMoreView.delegate = self;
    _loadMoreView.shouldAutoRotate = YES;
    
    [self.waterflowView addSubview:_pullView];
    [self.waterflowView addSubview:_loadMoreView];
    
    _refreshing = YES;
    _unreadCountButton.hidden = YES;
    [self loadMoreData];
}

#pragma mark - Notification

- (void)showUserByName:(NSNotification *)notification
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
    
    [self stackViewAtIndex:index push:vc withPageType:StackViewPageTypeUser pageDescription:screenName];
}

- (void)showUserByCell:(NSNotification *)notification
{
    NSDictionary *dictionary = notification.object;
    
    User *targetUser = [dictionary valueForKey:kNotificationObjectKeyUser];
    NSString *indexString = [dictionary valueForKey:kNotificationObjectKeyIndex];
    int index = [indexString intValue];
    
    NSString *vcIdentifier = [targetUser.screenName isEqualToString:self.currentUser.screenName] ? @"SelfProfileViewController" : @"FriendProfileViewController";
    
    UserProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:vcIdentifier];
    vc.currentUser = self.currentUser;
    vc.user = targetUser;
    
    [self stackViewAtIndex:index push:vc withPageType:StackViewPageTypeUser pageDescription:targetUser.screenName];
}

- (void)showCommentList:(NSNotification *)notification
{
    NSDictionary *dictionary = notification.object;
    
    Status *status = [dictionary valueForKey:kNotificationObjectKeyStatus];
    NSString *indexString = [dictionary valueForKey:kNotificationObjectKeyIndex];
    int index = indexString.intValue;
    
    CommentViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentViewController"];
    vc.currentUser = self.currentUser;
    vc.status = status;
    vc.type = CommentTableViewControllerTypeComment;
    
    [self stackViewAtIndex:index push:vc withPageType:StackViewPageTypeStatusComment pageDescription:status.statusID];
}

- (void)showRepostList:(NSNotification *)notification
{
    NSDictionary *dictionary = notification.object;
    
    Status *status = [dictionary valueForKey:kNotificationObjectKeyStatus];
    NSString *indexString = [dictionary valueForKey:kNotificationObjectKeyIndex];
    int index = indexString.intValue;
    
    CommentViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentViewController"];
    vc.currentUser = self.currentUser;
    vc.status = status;
    vc.type = CommentTableViewControllerTypeRepost;
    
    [self stackViewAtIndex:index push:vc withPageType:StackViewPageTypeStatusRepost pageDescription:status.statusID];
}

- (void)showSelfCommentList:(NSNotification *)notification
{
    NSDictionary *dictionary = notification.object;
    NSString *indexString = [dictionary valueForKey:kNotificationObjectKeyIndex];
    int index = indexString.intValue;
    [self showSelfCommentListWithStackIndex:index];
}

- (void)showSelfMentionList:(NSNotification *)notification
{
    NSDictionary *dictionary = notification.object;
    NSString *indexString = [dictionary valueForKey:kNotificationObjectKeyIndex];
    int index = indexString.intValue;
    [self showSelfMentionListWithStackIndex:index];
}

- (void)showSelfCommentListWithStackIndex:(int)index
{
    SelfCommentViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SelfCommentViewController"];
    vc.currentUser = self.currentUser;
    [self stackViewAtIndex:index push:vc withPageType:StackViewPageTypeStatusComment pageDescription:@""];
}

- (void)showSelfMentionListWithStackIndex:(int)index
{
    SelfCommentViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SelfMentionViewController"];
    vc.currentUser = self.currentUser;
    [self stackViewAtIndex:index push:vc withPageType:StackViewPageTypeUserMention pageDescription:@""];
}

- (void)showSelfProfileWithStackIndex:(int)index
{
    SelfProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SelfProfileViewController"];
    vc.currentUser = self.currentUser;
    vc.user = self.currentUser;
    vc.shouldShowFollowerList = YES;
    [self stackViewAtIndex:index push:vc withPageType:StackViewPageTypeUser pageDescription:self.currentUser.screenName];
}

- (void)showTopic:(NSNotification *)notification
{
    NSDictionary *dictionary = notification.object;
    
    NSString *searchKey = [dictionary valueForKey:kNotificationObjectKeySearchKey];
    NSString *indexString = [dictionary valueForKey:kNotificationObjectKeyIndex];
    int index = [indexString intValue];
    
    TopicViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"TopicViewController"];
    vc.currentUser = self.currentUser;
    vc.searchKey = searchKey;
    
    [self stackViewAtIndex:index push:vc withPageType:StackViewPageTypeTopic pageDescription:searchKey];
}

- (void)hideWaterflowView
{
    _stackViewController.view.backgroundColor = [UIColor clearColor];
}

- (void)showWaterflowView
{
    _stackViewController.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
}

- (void)refreshAfterDeletingStatuses:(NSNotification *)notification
{
    NSString *statusID = notification.object;
    [Status deleteStatusWithID:statusID inManagedObjectContext:self.managedObjectContext withObject:_coreDataIdentifier];
    [self.fetchedResultsController performFetch:nil];
    [self.waterflowView refresh];
}

- (void)refreshAfterDeletingComment:(NSNotification *)notification
{
    NSString *commentID = notification.object;
    [Comment deleteCommentWithID:commentID inManagedObjectContext:self.managedObjectContext withObject:kCoreDataIdentifierDefault];
}

#pragma mark Handle Unread Count Update
- (void)updateUnreadStatusCount
{
    int unreadStatusCount = self.currentUser.unreadStatusCount.intValue;
    if (unreadStatusCount != 0) {
        _unreadCountButton.hidden = NO;
        [_unreadCountButton setCount:unreadStatusCount];
    }
}

- (void)updateUnreadCommentCount
{
    int unreadCommentCount = self.currentUser.unreadCommentCount.intValue;
    if (unreadCommentCount != _unreadCommentIndicatorButton.previousCount) {
        _unreadCommentIndicatorButton.previousCount = unreadCommentCount;

        if (unreadCommentCount == 0) {
            if (!_unreadCommentIndicatorButton.hidden) {
                [_unreadIndicatorView removeIndicator:_unreadCommentIndicatorButton];
            }
        } else {
            if (_unreadCommentIndicatorButton.hidden) {
                [_unreadIndicatorView addNewIndicator:_unreadCommentIndicatorButton];
            } else {
                [_unreadCommentIndicatorButton showIndicatorUpdatedAnimation];
            }
        }
        
        NSString *content = [NSString stringWithFormat:@"     %i 条新评论", unreadCommentCount];
        [_unreadCommentIndicatorButton setTitle:content forState:UIControlStateNormal];
        [_unreadCommentIndicatorButton setTitle:content forState:UIControlStateHighlighted];
        [_unreadCommentIndicatorButton setTitle:content forState:UIControlStateDisabled];
    }
}

- (void)updateUnreadMentionCount
{
    int unreadMentionCount = self.currentUser.unreadMentionCount.intValue;
    if (unreadMentionCount != _unreadMentionIndicatorButton.previousCount) {
        _unreadMentionIndicatorButton.previousCount = unreadMentionCount;

        if (unreadMentionCount == 0) {
            if (!_unreadMentionIndicatorButton.hidden) {
                [_unreadIndicatorView removeIndicator:_unreadMentionIndicatorButton];
            }
        } else {
            if (_unreadMentionIndicatorButton.hidden) {
                [_unreadIndicatorView addNewIndicator:_unreadMentionIndicatorButton];
            } else {
                [_unreadMentionIndicatorButton showIndicatorUpdatedAnimation];
            }
        }
        
        NSString *content = [NSString stringWithFormat:@"     %i 条微博提到我", unreadMentionCount];
        [_unreadMentionIndicatorButton setTitle:content forState:UIControlStateNormal];
        [_unreadMentionIndicatorButton setTitle:content forState:UIControlStateHighlighted];
        [_unreadMentionIndicatorButton setTitle:content forState:UIControlStateDisabled];
    }
}

- (void)updateUnreadFollowCount
{
    int unreadFollowCount = self.currentUser.unreadFollowingCount.intValue;
    if (unreadFollowCount != _unreadFollowerIndicatorButton.previousCount) {
        _unreadFollowerIndicatorButton.previousCount = unreadFollowCount;
        
        if (unreadFollowCount == 0) {
            if (!_unreadFollowerIndicatorButton.hidden) {
                [_unreadIndicatorView removeIndicator:_unreadFollowerIndicatorButton];
            }
        } else {
            if (_unreadFollowerIndicatorButton.hidden) {
                [_unreadIndicatorView addNewIndicator:_unreadFollowerIndicatorButton];
            } else {
                [_unreadFollowerIndicatorButton showIndicatorUpdatedAnimation];
            }
        }
        
        NSString *content = [NSString stringWithFormat:@"     %i 位新粉丝", unreadFollowCount];
        [_unreadFollowerIndicatorButton setTitle:content forState:UIControlStateNormal];
        [_unreadFollowerIndicatorButton setTitle:content forState:UIControlStateHighlighted];
        [_unreadFollowerIndicatorButton setTitle:content forState:UIControlStateDisabled];
    }
}

#pragma mark - IBActions
#pragma mark Refresh

- (IBAction)refreshButtonClicked:(id)sender
{
    _refreshIndicatorView.hidden = NO;
    [_refreshIndicatorView startLoadingAnimation];
    
    [_pullView setState:PullToRefreshViewStateLoading];
    
    self.refreshButton.userInteractionEnabled = NO;
    if (_stackViewController) {
        [_stackViewController refresh];
    } else {
        [self refresh];
    }
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
    
    [self resetUnreadCountWithType:kWBClientResetCountTypeStatus];
}

#pragma mark Post

- (IBAction)didClickCreateStatusButton:(UIButton *)sender {
    PostViewController *vc = [PostViewController getNewStatusViewControllerWithDelegate:self];
    [vc showViewFromRect:sender.frame];
}

#pragma mark Stack View
- (IBAction)didClickGroupButton:(id)sender
{
    _groupButton.selected = !_groupButton.selected;
    NSString *notificationName = _groupButton.selected ? kNotificationNameShouldShowGroup : kNotificationNameShouldHideGroup;
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
}

- (IBAction)didClickSearchButton:(id)sender
{
    UserProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
    vc.currentUser = self.currentUser;
    
    [self stackViewAtIndex:INT64_MAX push:vc withPageType:StackViewPageTypeSearch pageDescription:self.currentUser.screenName];
}

- (IBAction)showProfileButtonClicked:(id)sender
{
    UserProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SelfProfileViewController"];
    vc.currentUser = self.currentUser;
    vc.screenName = self.currentUser.screenName;
    
    [self stackViewAtIndex:INT64_MAX push:vc withPageType:StackViewPageTypeUser pageDescription:vc.screenName];
}

- (void)stackViewAtIndex:(int)index
                    push:(StackViewPageController *)vc
            withPageType:(StackViewPageType)pageType
         pageDescription:(NSString *)pageDescription;
{
    BOOL stackViewExists = _stackViewController != nil;
    if (!stackViewExists) {
        [self enterStackView];
        
        _stackViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"StackViewController"];
        [_stackViewController.view resetOrigin:CGPointMake(0.0, 43.0)];
        [_stackViewController.view resetSize:self.waterflowView.frame.size];
        _stackViewController.currentUser = self.currentUser;
        _stackViewController.delegate = self;
        
        [_coverView resetOriginX:1024.0];
        [self.view insertSubview:_coverView belowSubview:_navigationView];
        [self.view insertSubview:_stackViewController.view aboveSubview:_coverView];
        
        [UIView animateWithDuration:0.3 animations:^{
            _stackViewController.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        }];
    }
    vc.pageType = pageType;
    vc.pageDescription = pageDescription;
    [_stackViewController insertStackPage:vc atIndex:index withPageType:pageType pageDescription:pageDescription];
    
}

#pragma mark Unread Indicator Button Actions
- (IBAction)didClickUnreadCommentButton:(UnreadIndicatorButton *)sender
{
    [self showSelfCommentListWithStackIndex:[_stackViewController stackTopIndex]];
    [self resetUnreadCountWithType:kWBClientResetCountTypeComment];
    [_unreadIndicatorView removeIndicator:sender];
    sender.previousCount = 0;
}

- (IBAction)didClickUnreadFollowerButton:(UnreadIndicatorButton *)sender
{
    [self showSelfProfileWithStackIndex:[_stackViewController stackTopIndex]];
    [self resetUnreadCountWithType:kWBClientResetCountTypeFollower];
    [_unreadIndicatorView removeIndicator:sender];
    sender.previousCount = 0;
}

- (IBAction)didClickUnreadMentionButton:(UnreadIndicatorButton *)sender
{
    [self showSelfMentionListWithStackIndex:[_stackViewController stackTopIndex]];
    [self resetUnreadCountWithType:kWBClientResetCountTypeMention];
    [_unreadIndicatorView removeIndicator:sender];
    sender.previousCount = 0;
}



#pragma mark - Data Methods
- (void)refresh
{
    _unreadCountButton.hidden = YES;
    int unreadStatusCount = self.currentUser.unreadStatusCount.intValue;
    if (unreadStatusCount != 0) {
        _refreshing = YES;
        [self loadMoreData];
    } else {
        [_pullView performSelector:@selector(finishedLoading) withObject:nil afterDelay:1.0];
    }
}

- (void)clearData
{
    for (Status *status in self.fetchedResultsController.fetchedObjects) {
        [self.managedObjectContext deleteObject:status];
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
                newStatus = [Status insertStatus:dict inManagedObjectContext:self.managedObjectContext withOperatingObject:kCoreDataIdentifierDefault];
                newStatus.forCastView = [NSNumber numberWithBool:YES];
                
                CGFloat imageHeight = [self randomImageHeight];
                CGFloat cardHeight = [CardViewController heightForStatus:newStatus andImageHeight:imageHeight];
                newStatus.cardSizeImageHeight = [NSNumber numberWithFloat:imageHeight];
                newStatus.cardSizeCardHeight = [NSNumber numberWithFloat:cardHeight];
                
                [self.currentUser addFriendsStatusesObject:newStatus];
            }
            
            [self.managedObjectContext processPendingChanges];
            [self.fetchedResultsController performFetch:nil];
            if (_refreshing) {
                [self refreshEnded];
                [self.waterflowView refresh];
            } else {
                [self.waterflowView reloadData];
            }
            _hasMoreViews = dictArray.count == 20;
        }
        
        [_pullView finishedLoading];
        [_loadMoreView finishedLoading:_hasMoreViews];
        [_loadMoreView resetPosition];
        _loading = NO;
        _refreshing = NO;
    }];
    
    long long maxID = ((Status *)self.fetchedResultsController.fetchedObjects.lastObject).statusID.longLongValue - 1;
    maxID = maxID < 0 ? 0 : maxID;
    NSString *maxIDString = _refreshing ? nil : [NSString stringWithFormat:@"%lld", maxID];
    
    [client getFriendsTimelineSinceID:nil 
                                maxID:maxIDString
                       startingAtPage:0
                                count:20 
                              feature:0];
    
//    WBClient *client1 = [WBClient client];
//    [client1 setCompletionBlock:^(WBClient *client) {
//        if (!client.hasError) {
//            NSLog(@"%@", client.responseJSONObject);
//        } else {
//            NSLog(@"error! \n%@", client.responseJSONObject);
//        }
//    }];
//    [client1 searchUser:@"gab"];
}

- (void)resetUnreadCountWithType:(NSString *)type
{
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client){
        if (!client.hasError) {
            if ([type isEqualToString:kWBClientResetCountTypeComment]) {
                self.currentUser.unreadCommentCount = [NSNumber numberWithInt:0];
            } else if ([type isEqualToString:kWBClientResetCountTypeFollower]) {
                self.currentUser.unreadFollowingCount = [NSNumber numberWithInt:0];
            } else if ([type isEqualToString:kWBClientResetCountTypeMention]) {
                self.currentUser.unreadMentionCount = [NSNumber numberWithInt:0];
            } else if ([type isEqualToString:kWBClientResetCountTypeStatus]){
                self.currentUser.unreadStatusCount = [NSNumber numberWithInt:0];
            }
        }
    }];
    [client resetUnreadCount:type];
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
 
    request.predicate = [NSPredicate predicateWithFormat:@"isFriendsStatusOf == %@ && operatable == %@", self.currentUser, [NSNumber numberWithBool:NO]];
                  
}

- (NSString *)customCellClassNameForIndex:(NSIndexPath *)indexPath
{
    return @"CardTableViewCell";
}

#pragma mark - Stack View Controller Delegate
- (void)clearStack
{
    [_coverView removeFromSuperview];
    [UIView animateWithDuration:0.3 animations:^{
        _stackViewController.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [_stackViewController.view removeFromSuperview];
        _stackViewController = nil;
        [User deleteAllTempUsersInManagedObjectContext:self.managedObjectContext];
        [Comment deleteAllTempCommentsInManagedObjectContext:self.managedObjectContext];
        [Status deleteAllTempStatusesInManagedObjectContext:self.managedObjectContext];
        
        [self exitStackView];
    }];
}

- (void)enterStackView
{
    _waterflowView.scrollsToTop = NO;
    [UIView animateWithDuration:0.3 animations:^{
        _unreadCountButton.alpha = 0.0;
    }];
}

- (void)exitStackView
{
    _waterflowView.scrollsToTop = YES;
    [UIView animateWithDuration:0.3 animations:^{
        _unreadCountButton.alpha = 1.0;
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

#pragma mark - PullToRefreshViewDelegate
- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view
{
    [self refresh];
}

- (void)loadMoreViewShouldLoadMoreView:(LoadMoreView *)view
{
    [self loadMoreData];
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
                                                                      pageIndex:0
                                                                    currentUser:self.currentUser];
        
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