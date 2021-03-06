//
//  CastViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-4-18.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "CastViewController.h"
#import "UserProfileViewController.h"
#import "UIImageView+Addition.h"
#import "UIView+Resize.h"
#import "ResourceList.h"
#import "WBClient.h"
#import "Status.h"
#import "Comment.h"
#import "User.h"
#import "Group.h"
#import "WaterflowCardCell.h"
#import "WaterflowDividerCell.h"
#import "PostViewController.h"
#import "UIApplication+Addition.h"
#import "CommentViewController.h"
#import "SelfCommentViewController.h"
#import "SelfProfileViewController.h"
#import "TopicViewController.h"
#import "SearchUserResultViewController.h"
#import "NSNotificationCenter+Addition.h"
#import "SelfMentionViewController.h"
#import "ErrorIndicatorViewController.h"
#import "MessageConversationViewController.h"
#import "Conversation.h"
#import "NSUserDefaults+Addition.h"
#import "LoginViewController.h"

#define kStackViewDefaultDescription @"kStackViewDefaultDescription"

@interface CastViewController () {
    BOOL _loading;
    BOOL _notificationAlreadySet;
    BOOL _hasMoreViews;
    BOOL _refreshing;
    NSString *_dataSourceID;
    NSString *_previousStatusID;
    NSString *_prevPostContent;
    NSInteger _nextPage;
    CastviewDataSource _dataSource;
    ErrorIndicatorViewController *_errorIndicateViewController;
}

@property (nonatomic, strong) UIView *coverView;

@end

@implementation CastViewController

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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpVariables];
    [self initialLoad];
    
    if([NSUserDefaults shouldPostRecommendVCardWeibo]) {
        [self postRecommandVCardWeibo];
    }
}

- (void)setUpVariables
{
    _loading = NO;
    _hasMoreViews = YES;
    _nextPage = 1;
    _notificationAlreadySet = NO;
    _refreshIndicatorView.hidden = YES;
    _postIndicatorView.hidden = YES;
    _refreshing = NO;
    _previousStatusID = @"";
    _dataSource = CastviewDataSourceNone;
    _coverView = [[UIView alloc] initWithFrame:CGRectMake(1024.0, 0.0, 0.0, 0.0)];
    _coverView.backgroundColor = [UIColor blackColor];
    _coverView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.coreDataIdentifier = kCoreDataIdentifierDefault;
    
    [self.profileImageView loadImageFromURL:self.currentUser.profileImageURL completion:nil];
    
    self.waterflowView.flowdatasource = self;
    self.waterflowView.flowdelegate = self;
    self.waterflowView.animationCover = self.waterflowViewAnimationCover;
    
    _pullView = [[PullToRefreshView alloc] initWithScrollView:(UIScrollView *)self.waterflowView];
    _pullView.delegate = self;
    _pullView.shouldAutoRotate = YES;
    _loadMoreView = [[LoadMoreView alloc] initWithScrollView:(UIScrollView *)self.waterflowView];
    _loadMoreView.delegate = self;
    _loadMoreView.shouldAutoRotate = YES;
    [self.waterflowView insertSubview:_pullView atIndex:kWaterflowViewPullToRefreshViewIndex];
    [self.waterflowView addSubview:_loadMoreView];
    [self.waterflowView setContentEmptyIndicatorView:_contentEmptyIndicatorView];
    
    UserAccountInfo *info = [NSUserDefaults getUserAccountInfoWithUserID:self.currentUser.userID];
    if (info.groupIndex != 0) {
        [self changeCastViewDataSouceWithType:info.groupType description:info.groupTitle dataSourceID:info.groupDataSourceID needRefresh:NO];
    }
    
    [_loadMoreView resetLayoutTo:[UIApplication currentInterface]];
    [_pullView resetLayoutTo:[UIApplication currentInterface]];
    
    [_unreadFollowerIndicatorButton resetOriginY:240];
    [_unreadCommentIndicatorButton resetOriginY:240];
    [_unreadMentionIndicatorButton resetOriginY:240];
    [_unreadMentionCommentIndicatorButton resetOriginY:240];
    [_unreadMessageIndicatorButton resetOriginY:240];
}

- (void)setUpNotification
{
    if (_notificationAlreadySet) {
        return;
    }
    _notificationAlreadySet = YES;
    [_pullView addObserver];
    
    [NSNotificationCenter registerChangeUserAvatarNotificationWith:@selector(changeUserAvatar) target:self];
    
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
               selector:@selector(showUserSearchList:)
                   name:kNotificationNameShouldShowUserSearchList
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
               selector:@selector(showConversation:)
                   name:kNotificationNameShouldShowConversation
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
    [center addObserver:self
               selector:@selector(updateUnreadMentionCommentCount)
                   name:kNotificationNameShouldUpdateUnreadMentionCommentCount
                 object:nil];
    [center addObserver:self
               selector:@selector(updateUnreadMessageCount)
                   name:kNotificationNameShouldUpdateUnreadMessageCount
                 object:nil];
    
    [center addObserver:self
               selector:@selector(changeCastviewDataSource:)
                   name:kNotificationNameShouldChangeCastviewDataSource
                 object:nil];
    
    [center addObserver:self
               selector:@selector(showPostIndicator)
                   name:kNotificationNameShouldShowPostIndicator
                 object:nil];
    [center addObserver:self
               selector:@selector(hidePostIndicator)
                   name:kNotificationNameShouldHidePostIndicator
                 object:nil];
    [center addObserver:self
               selector:@selector(clearStack)
                   name:kNotificationNameShouldClearStack
                 object:nil];
    [center addObserver:self
               selector:@selector(refreshWaterflowView)
                   name:kNotificationNameShouldRefreshWaterflowView
                 object:nil];
    [center addObserver:self
               selector:@selector(refreshWaterflowView)
                   name:kNotificationNameDidChangeFontSize
                 object:nil];
    [center addObserver:self
               selector:@selector(resetRefreshingAnimation)
                   name:UIApplicationDidBecomeActiveNotification
                 object:nil];
    
    [NSNotificationCenter registerShouldPostRecommendVCardWeiboNotificationWithSelector:@selector(postRecommandVCardWeibo) target:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setUpNotification];
    [self performSelector:@selector(resetChangeAccountButtonImage) withObject:nil afterDelay:0.5];
}

- (void)resetChangeAccountButtonImage
{
    if ([NSUserDefaults getLoginUserArray].count > 1) {
        [self.changeAccountButton setImage:[UIImage imageNamed:@"topbar_change.png"] forState:UIControlStateNormal];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    _notificationAlreadySet = NO;
    [_pullView removeObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Initializing Methods
- (void)initialLoad
{
    [self.fetchedResultsController performFetch:nil];
    [self performSelector:@selector(setUpWaterflowView) withObject:nil afterDelay:0.5];
}

- (void)setUpWaterflowView
{
    if (self.fetchedResultsController.fetchedObjects.count == 0) {
        [self refresh];
    }
    [self.waterflowView refresh];
    [_loadMoreView resetPosition];
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
    vc.status = status;
    vc.type = CommentTableViewControllerTypeRepost;
    
    [self stackViewAtIndex:index push:vc withPageType:StackViewPageTypeStatusRepost pageDescription:status.statusID];
}

- (void)showSelfCommentList:(NSNotification *)notification
{
    NSDictionary *dictionary = notification.object;
    NSString *indexString = [dictionary valueForKey:kNotificationObjectKeyIndex];
    int index = indexString.intValue;
    [self showSelfCommentListWithStackIndex:index refreshing:NO];
}

- (void)showSelfMentionList:(NSNotification *)notification
{
    NSDictionary *dictionary = notification.object;
    NSString *indexString = [dictionary valueForKey:kNotificationObjectKeyIndex];
    int index = indexString.intValue;
    [self showSelfMentionListWithStackIndex:index refreshing:NO];
}

- (void)showSelfCommentListWithStackIndex:(int)index refreshing:(BOOL)refreshing
{
    SelfCommentViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SelfCommentViewController"];
    vc.loadWithPurpose = refreshing;
    [self stackViewAtIndex:index push:vc withPageType:StackViewPageTypeStatusComment pageDescription:kStackViewDefaultDescription];
}

- (void)showSelfMentionListWithStackIndex:(int)index refreshing:(BOOL)refreshing
{
    SelfMentionViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SelfMentionViewController"];
    vc.loadWithPurpose = refreshing;
    vc.shouldShowFirst = YES;
    [self stackViewAtIndex:index push:vc withPageType:StackViewPageTypeUserMention pageDescription:kStackViewDefaultDescription];
}

- (void)showSelfProfileWithStackIndex:(int)index
{
    SelfProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SelfProfileViewController"];
    vc.loadWithPurpose = YES;
    vc.user = self.currentUser;
    vc.shouldShowFollowerList = YES;
    [self stackViewAtIndex:index push:vc withPageType:StackViewPageTypeUser pageDescription:self.currentUser.screenName];
}

- (void)showMentionComment:(int)index
{
    SelfMentionViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SelfMentionViewController"];
    vc.loadWithPurpose = YES;
    vc.shouldShowFirst = NO;
    [self stackViewAtIndex:index push:vc withPageType:StackViewPageTypeUserMention pageDescription:kStackViewDefaultDescription];
}

- (void)showMessage:(int)index
{
    
}

- (void)showTopic:(NSNotification *)notification
{
    NSDictionary *dictionary = notification.object;
    
    NSString *searchKey = [dictionary valueForKey:kNotificationObjectKeySearchKey];
    NSString *indexString = [dictionary valueForKey:kNotificationObjectKeyIndex];
    int index = [indexString intValue];
    
    TopicViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"TopicViewController"];
    vc.searchKey = searchKey;
    
    [self stackViewAtIndex:index push:vc withPageType:StackViewPageTypeTopic pageDescription:searchKey];
}

- (void)showUserSearchList:(NSNotification *)notification
{
    NSDictionary *dictionary = notification.object;
    
    NSString *searchKey = [dictionary valueForKey:kNotificationObjectKeySearchKey];
    NSString *indexString = [dictionary valueForKey:kNotificationObjectKeyIndex];
    int index = [indexString intValue];
    
    SearchUserResultViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchUserResultViewController"];
    vc.searchKey = searchKey;
    
    [self stackViewAtIndex:index push:vc withPageType:StackViewPageTypeTopic pageDescription:[searchKey stringByAppendingString:@"_userSearch"]];
}

- (void)showMessageListShouldRefresh:(BOOL)shouldRefresh
{
    StackViewPageController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MessageListViewController"];
    
    vc.loadWithPurpose = shouldRefresh;
    
    [self stackViewAtIndex:INT16_MAX push:vc withPageType:StackViewPageTypeDMList pageDescription:kStackViewDefaultDescription];
}

- (void)showConversation:(NSNotification *)notification
{
    NSDictionary *dictionary = notification.object;
    
    Conversation *conversation = [dictionary objectForKey:kNotificationObjectKeyConversation];
    NSString *indexString = [dictionary valueForKey:kNotificationObjectKeyIndex];
    NSNumber *shouldRefresh = [dictionary valueForKey:kNotificationObjectKeyShouldRefresh];
    int index = [indexString intValue];
    
    MessageConversationViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MessageConversationViewController"];
    vc.conversation = conversation;
    vc.shouldAutomaticallyBecomeFirstResponder = shouldRefresh.boolValue;
    
    [self stackViewAtIndex:index push:vc withPageType:StackViewPageTypeDMConversation pageDescription:conversation.targetUserID];
}

- (void)hideWaterflowView
{
    self.view.userInteractionEnabled = NO;
//    _stackViewController.view.backgroundColor = [UIColor clearColor];
}

- (void)showWaterflowView
{
//    _stackViewController.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
}

- (void)disableWaterflowView
{
    self.view.userInteractionEnabled = NO;
}

- (void)refreshWaterflowView
{
    [_waterflowView refresh];
}

- (void)refreshAfterDeletingStatuses:(NSNotification *)notification
{
    NSDictionary *dict = notification.object;
    NSString *coredataIdentifier = [dict objectForKey:kNotificationObjectKeyCoredataIdentifier];
    if ([coredataIdentifier isEqualToString:self.coreDataIdentifier]) {
        NSString *statusID = [dict objectForKey:kNotificationObjectKeyStatusID];
        [Status deleteStatusWithID:statusID inManagedObjectContext:self.managedObjectContext withObject:self.coreDataIdentifier];
        [self.fetchedResultsController performFetch:nil];
        [self.waterflowView refresh];
    }
}

- (void)refreshAfterDeletingComment:(NSNotification *)notification
{
    NSString *commentID = notification.object;
    [Comment deleteCommentWithID:commentID inManagedObjectContext:self.managedObjectContext withObject:kCoreDataIdentifierDefault];
}

- (void)resetRefreshingAnimation
{
    [_pullView finishedLoading];
    [self hidePostIndicator];
    [self refreshEnded];
}

#pragma mark Handle Unread Count Update
- (void)updateUnreadStatusCount
{
    int unreadStatusCount = self.currentUser.unreadStatusCount.intValue;
    if (unreadStatusCount != 0 && !_loading) {
        if (_dataSource != CastviewDataSourceNone) {
            _unreadCountButton.hidden = YES;
        } else {
            _unreadCountButton.hidden = NO;
            [_unreadCountButton setCount:unreadStatusCount];
        }
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
            
            NSString *content = [NSString stringWithFormat:@"     %i 条新评论", unreadCommentCount];
            [_unreadCommentIndicatorButton setTitle:content forState:UIControlStateNormal];
            [_unreadCommentIndicatorButton setTitle:content forState:UIControlStateHighlighted];
            [_unreadCommentIndicatorButton setTitle:content forState:UIControlStateDisabled];
        }
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

- (void)updateUnreadMentionCommentCount
{
    int unreadMentionCommentCount = self.currentUser.unreadMentionComment.intValue;
    if (unreadMentionCommentCount != _unreadMentionCommentIndicatorButton.previousCount) {
        _unreadMentionCommentIndicatorButton.previousCount = unreadMentionCommentCount;
        
        if (unreadMentionCommentCount == 0) {
            if (!_unreadMentionCommentIndicatorButton.hidden) {
                [_unreadIndicatorView removeIndicator:_unreadMentionCommentIndicatorButton];
            }
        } else {
            if (_unreadMentionCommentIndicatorButton.hidden) {
                [_unreadIndicatorView addNewIndicator:_unreadMentionCommentIndicatorButton];
            } else {
                [_unreadMentionCommentIndicatorButton showIndicatorUpdatedAnimation];
            }
        }
        
        NSString *content = [NSString stringWithFormat:@"     %i 条评论提到我", unreadMentionCommentCount];
        [_unreadMentionCommentIndicatorButton setTitle:content forState:UIControlStateNormal];
        [_unreadMentionCommentIndicatorButton setTitle:content forState:UIControlStateHighlighted];
        [_unreadMentionCommentIndicatorButton setTitle:content forState:UIControlStateDisabled];
    }
}

- (void)updateUnreadMessageCount
{
    int unreadMessageCount = self.currentUser.unreadMessageCount.intValue;
    if (unreadMessageCount != _unreadMessageIndicatorButton.previousCount) {
        _unreadMessageIndicatorButton.previousCount = unreadMessageCount;
        
        if (unreadMessageCount == 0) {
            if (!_unreadMessageIndicatorButton.hidden) {
                [_unreadIndicatorView removeIndicator:_unreadMessageIndicatorButton];
            }
        } else {
            if (_unreadMessageIndicatorButton.hidden) {
                [_unreadIndicatorView addNewIndicator:_unreadMessageIndicatorButton];
            } else {
                [_unreadMessageIndicatorButton showIndicatorUpdatedAnimation];
            }
        }
        
        NSString *content = [NSString stringWithFormat:@"     %i 条新私信", unreadMessageCount];
        [_unreadMessageIndicatorButton setTitle:content forState:UIControlStateNormal];
        [_unreadMessageIndicatorButton setTitle:content forState:UIControlStateHighlighted];
        [_unreadMessageIndicatorButton setTitle:content forState:UIControlStateDisabled];
    }
}

#pragma mark DataSource
- (void)changeCastviewDataSource:(NSNotification *)notification
{
    NSDictionary *dict = notification.object;
    NSString *typeString = [dict objectForKey:kNotificationObjectKeyDataSourceType];
    NSString *description = [dict objectForKey:kNotificationObjectKeyDataSourceDescription];
    NSString *dataSouceID = [dict objectForKey:kNotificationObjectKeyDataSourceID];
    
    if (_errorIndicateViewController == nil) {
        _errorIndicateViewController = [ErrorIndicatorViewController showErrorIndicatorWithType:ErrorIndicatorViewControllerTypeLoading contentText:nil animated:YES];
    }
    
    [self changeCastViewDataSouceWithType:typeString description:description dataSourceID:dataSouceID needRefresh:YES];
}

- (void)changeCastViewDataSouceWithType:(NSString *)typeString
                            description:(NSString *)description
                           dataSourceID:(NSString *)dataSourceID
                            needRefresh:(BOOL)needRefresh
{
    int type = typeString.intValue;
    _dataSourceID = dataSourceID;
    if ([_dataSourceID isEqualToString:kGroupIDDefault]) {
        [self returnToNormalTimeline];
        
        [_waterflowView hideInfoBar:NO];
    } else {
        if (type == kGroupTypeFavourite) {
            _dataSource = CastviewDataSourceFavourite;
        } else if (type == kGroupTypeGroup) {
            _dataSource = CastviewDataSourceGroup;
        } else if (type == kGroupTypeTopic) {
            _dataSource = CastviewDataSourceTopic;
        } else {
            _dataSource = CastviewDataSourceNone;
        }
        [_waterflowView showInfoBarWithTitleName:description];
        [self updateUnreadStatusCount];
        
        if (needRefresh) {
            [self refresh];
        }
    }
    _previousStatusID = @"";
}

- (void)returnToNormalTimeline
{
    _dataSource = CastviewDataSourceNone;
    _refreshing = YES;
    [self loadMoreData];
}

#pragma mark Change User Avatar
- (void)changeUserAvatar
{
    [self.profileImageView loadImageFromURL:self.currentUser.largeAvatarURL completion:nil];
}

#pragma mark Post Indicator
- (void)showPostIndicator
{
    _postIndicatorView.hidden = NO;
    [_postIndicatorView startLoadingAnimation];
        
    self.createStatusButton.alpha = 0.0;
}

- (void)hidePostIndicator
{
    [UIView animateWithDuration:0.3 animations:^{
        _postIndicatorView.alpha = 0.0;
        self.createStatusButton.alpha = 1.0;
    } completion:^(BOOL finished) {
        _postIndicatorView.hidden = YES;
        _postIndicatorView.alpha = 1.0;
    }];
}

#pragma mark - IBActions
#pragma mark Account
- (IBAction)didClickChangeAccountButton:(UIButton *)sender
{
    NSString *firstTitle = [NSUserDefaults getLoginUserArray].count > 1 ? @"切换用户" : @"添加新帐户";
    NSString *secondTitle = [NSUserDefaults getLoginUserArray].count > 1 ? @"添加新帐户" : nil;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self 
                                                    cancelButtonTitle:nil 
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:firstTitle, secondTitle, nil];
    actionSheet.delegate = self;
    [actionSheet showFromRect:sender.bounds inView:sender animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if ([NSUserDefaults getLoginUserArray].count > 1) {
            [[[LoginViewController alloc] initWithType:LoginViewControllerTypeDefault] show];
        } else {
            [[[LoginViewController alloc] initWithType:LoginViewControllerTypeCreateNewUser] show];
        }
        
    } else if (buttonIndex == 1){
        [[[LoginViewController alloc] initWithType:LoginViewControllerTypeCreateNewUser] show];
    }
}

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
    if (_errorIndicateViewController) {
        [_errorIndicateViewController dismissViewAnimated:YES completion:nil];
        _errorIndicateViewController = nil;
    }
}

#pragma mark Post

- (IBAction)didClickCreateStatusButton:(UIButton *)sender {
    PostViewController *vc = nil;
    if (_postErrorIndicator.hidden) {
        vc = [PostViewController getNewStatusViewControllerWithDelegate:self];
    } else {
        _postErrorIndicator.hidden = YES;
        vc = [PostViewController getNewStatusViewControllerWithPrefixContent:_prevPostContent image:nil delegate:self];
    }
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
    StackViewPageController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
    
    [self stackViewAtIndex:INT16_MAX push:vc withPageType:StackViewPageTypeSearch pageDescription:self.currentUser.screenName];
}

- (IBAction)didClickShowDirectMessageButton:(UIButton *)sender
{
    [self showMessageListShouldRefresh:NO];
}

- (IBAction)showProfileButtonClicked:(id)sender
{
    UserProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SelfProfileViewController"];
    vc.screenName = self.currentUser.screenName;
    
    [self stackViewAtIndex:INT16_MAX push:vc withPageType:StackViewPageTypeUser pageDescription:vc.screenName];
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
    [self showSelfCommentListWithStackIndex:[_stackViewController stackTopIndex] refreshing:YES];
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
    [self showSelfMentionListWithStackIndex:[_stackViewController stackTopIndex] refreshing:YES];
    [self resetUnreadCountWithType:kWBClientResetCountTypeMention];
    [_unreadIndicatorView removeIndicator:sender];
    sender.previousCount = 0;
}

- (IBAction)didClickUnreadMentionCommentButton:(UnreadIndicatorButton *)sender
{
    [self showMentionComment:[_stackViewController stackTopIndex]];
    [self resetUnreadCountWithType:kWBClientResetCountTypeMetionComment];
    [_unreadIndicatorView removeIndicator:sender];
    sender.previousCount = 0;
}

- (IBAction)didClickUnreadMessageButton:(UnreadIndicatorButton *)sender
{
    [self showMessage:[_stackViewController stackTopIndex]];
    [self resetUnreadCountWithType:kWBClientResetCountTypeMessage];
    [_unreadIndicatorView removeIndicator:sender];
    sender.previousCount = 0;
    
    [self showMessageListShouldRefresh:YES];
}



#pragma mark - Data Methods
- (void)refresh
{
    _nextPage = 1;
    _refreshing = YES;
    _unreadCountButton.hidden = YES;
    [self loadMoreData];
}

- (void)clearData
{
    [self.fetchedResultsController performFetch:nil];
    for (Status *status in self.fetchedResultsController.fetchedObjects) {
        [self.managedObjectContext deleteObject:status];
    }
    [User deleteRedundantUsersInManagedObjectContext:self.managedObjectContext];
}

- (void)loadMoreData
{
    if (_loading) {
        return;
    }
    _loading = YES;
    
    [NSNotificationCenter postWillReloadCardCellNotification];
    [NSUserDefaults setReloadingCardCellStatus:YES];
    
    if (self.fetchedResultsController.fetchedObjects.count > 0) {
        Status *status = [self.fetchedResultsController.fetchedObjects objectAtIndex:0];
        _previousStatusID = status.statusID;
    }
    
    WBClient *client = [WBClient client];
    
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            NSArray *dictArray = client.responseJSONObject;
            if (_refreshing) {
                [self clearData];
            }
            
            for (NSDictionary *rawDict in dictArray) {
                NSDictionary *dict = rawDict;
                if (_dataSource == CastviewDataSourceFavourite) {
                    dict = [rawDict objectForKey:@"status"];
                }
                
                Status *newStatus = nil;
                newStatus = [Status insertStatus:dict inManagedObjectContext:self.managedObjectContext withOperatingObject:kCoreDataIdentifierDefault operatableType:kOperatableTypeDefault];
                newStatus.forCastView = @(YES);
                
                CGFloat imageHeight = [self randomImageHeight];
                CGFloat cardHeight = [CardViewController heightForStatus:newStatus andImageHeight:imageHeight timeStampEnabled:[NSUserDefaults isDateDisplayEnabled] picEnabled:[NSUserDefaults isPictureEnabled]];
                newStatus.cardSizeImageHeight = @(imageHeight);
                newStatus.cardSizeCardHeight = @(cardHeight);
                
                [self.currentUser addFriendsStatusesObject:newStatus];
            }
            
            [self.managedObjectContext processPendingChanges];
            [self.fetchedResultsController performFetch:nil];
            
            if (self.fetchedResultsController.fetchedObjects.count > 0) {
                Status *status = [self.fetchedResultsController.fetchedObjects objectAtIndex:0];
                if (![status.statusID isEqualToString:_previousStatusID] && _refreshing) {
                    _previousStatusID = status.statusID;
                    [[SoundManager sharedManager] playReloadSoundAfterDelay:0.7f];
                }
            }
            
            if (_refreshing) {
                [self.waterflowView refresh];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldSaveContext object:nil];
            } else {
                [self.waterflowView reloadData];
            }
            _hasMoreViews = dictArray.count > 15;
        }
        
        [NSNotificationCenter postDidReloadCardCellNotification];
        [NSUserDefaults setReloadingCardCellStatus:NO];
        [self refreshEnded];
        [self.waterflowView checkContentEmpty];
        [_pullView finishedLoading];
        [_loadMoreView finishedLoading:_hasMoreViews];
        [_loadMoreView resetPosition];
        _loading = NO;
        _refreshing = NO;
    }];
    
    long long maxID = ((Status *)self.fetchedResultsController.fetchedObjects.lastObject).statusID.longLongValue - 1;
    maxID = maxID < 0 ? 0 : maxID;
    NSString *maxIDString = _refreshing ? nil : [NSString stringWithFormat:@"%lld", maxID];
    
    if (_dataSource == CastviewDataSourceNone) {
        [client getFriendsTimelineSinceID:nil
                                    maxID:maxIDString
                           startingAtPage:0
                                    count:20 
                                  feature:0];
    } else if (_dataSource == CastviewDataSourceFavourite) {
        [client getFavouritesWithPage:_nextPage++
                                count:50];
    } else if (_dataSource == CastviewDataSourceGroup) {
        [client getGroupTimelineWithGroupID:_dataSourceID
                                    sinceID:nil
                                      maxID:maxIDString
                             startingAtPage:0
                                      count:20
                                    feature:0];
    } else if (_dataSource == CastviewDataSourceTopic) {
        NSDate *startDate = _refreshing ? nil : ((Status *)self.fetchedResultsController.fetchedObjects.lastObject).createdAt;
        
        [client searchTopic:_dataSourceID
                 startingAt:startDate
                   clearDup:YES
                      count:20];
    }
    
}

- (void)resetUnreadCountWithType:(NSString *)type
{
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client){
        if (!client.hasError) {
            if ([type isEqualToString:kWBClientResetCountTypeComment]) {
                self.currentUser.unreadCommentCount = @0;
            } else if ([type isEqualToString:kWBClientResetCountTypeFollower]) {
                self.currentUser.unreadFollowingCount = @0;
            } else if ([type isEqualToString:kWBClientResetCountTypeMention]) {
                self.currentUser.unreadMentionCount = @0;
            } else if ([type isEqualToString:kWBClientResetCountTypeStatus]){
                self.currentUser.unreadStatusCount = @0;
            } else if ([type isEqualToString:kWBClientResetCountTypeMetionComment]){
                self.currentUser.unreadMentionComment = @0;
            } else if ([type isEqualToString:kWBClientResetCountTypeMessage]){
                self.currentUser.unreadMessageCount = @0;
            }
        }
    }];
    [client resetUnreadCount:type];
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration 
{
    [self.waterflowView adjustViewsForOrientation:toInterfaceOrientation];
    [_loadMoreView resetLayoutTo:toInterfaceOrientation];
    [_pullView resetLayoutTo:toInterfaceOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.view resetHeight:[UIApplication screenHeight] - 20.0];
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
	
    sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
    request.sortDescriptors = @[sortDescriptor];
    request.entity = [NSEntityDescription entityForName:@"Status" inManagedObjectContext:self.managedObjectContext];
    request.predicate = [NSPredicate predicateWithFormat:@"isFriendsStatusOf == %@ && currentUserID == %@", self.currentUser, self.currentUser.userID];
                  
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
        [_stackViewController deleteAllPages];
        [_stackViewController.view removeFromSuperview];
        [_stackViewController.stackView removeFromSuperview];
        _stackViewController = nil;
        
        [Comment deleteAllTempCommentsInManagedObjectContext:self.managedObjectContext];
        [User deleteAllTempUsersInManagedObjectContext:self.managedObjectContext];
        [Status deleteAllTempStatusesInManagedObjectContext:self.managedObjectContext];
        [Conversation deleteEmptyConversationsOfUser:self.currentUser.userID managedObjectContext:self.managedObjectContext];
        [self.managedObjectContext processPendingChanges];
        
        [self exitStackView];
    }];
}

- (void)enterStackView
{
    _waterflowView.scrollsToTop = NO;
    _groupButton.enabled = NO;
    [UIView animateWithDuration:0.3 animations:^{
        _unreadCountButton.alpha = 0.0;
    }];
}

- (void)exitStackView
{
    _waterflowView.scrollsToTop = YES;
    _groupButton.enabled = YES;
    self.view.userInteractionEnabled = YES;
    [UIView animateWithDuration:0.3 animations:^{
        _unreadCountButton.alpha = 1.0;
    }];
}

- (void)stackViewScrolledWithOffset:(CGFloat)scrollViewOffsetX width:(CGFloat)scrollViewWidth
{
    CGFloat screenWidth = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? 768.0 : 1024.0;
    CGFloat screenHeight = screenWidth == 768.0 ? 1024.0 : 768.0;
    CGFloat originX = screenWidth - scrollViewOffsetX;
//    CGFloat width = scrollViewWidth > screenWidth ? screenWidth : scrollViewWidth;

    [_coverView setFrame:CGRectMake(originX, 0.0, scrollViewWidth, screenHeight)];
}

#pragma mark - PullToRefreshViewDelegate
- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view
{
    [self refresh];
}

#pragma mark - WaterflowDelegate
- (void)didDragWaterflowViewWithOffset:(CGFloat)offset
{    
    if ([_delegate respondsToSelector:@selector(didDragCastViewWithOffset:)]) {
        [_delegate didDragCastViewWithOffset:offset];
    }
}

- (void)didSwipeWaterflowView
{
    if ([_delegate respondsToSelector:@selector(didSwipeCastView)]) {
        [_delegate didSwipeCastView];
    }
}

- (void)didEndDraggingWaterflowView:(CGFloat)offset
{
    if ([_delegate respondsToSelector:@selector(didEndDraggingCastViewWithOffset:)]) {
        [_delegate didEndDraggingCastViewWithOffset:offset];
    }
}

- (void)didClickReturnToNormalTimelineButton
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameDidReturnToNormalTimeline object:nil];
    
    [self returnToNormalTimeline];
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
        } else if(layoutUnit.unitType == UnitTypeDivider) {
            cell = [[WaterflowDividerCell alloc] initWithReuseIdentifier:CellIdentifier currentUser:self.currentUser];
        } else {
            cell = [[WaterflowCell alloc] initWithReuseIdentifier:CellIdentifier currentUser:self.currentUser];
        }
	}
    
    if (layoutUnit.unitType == UnitTypeCard) {
        if (self.fetchedResultsController.fetchedObjects.count > layoutUnit.dataIndex) {
            Status *targetStatus = (Status*)[self.fetchedResultsController.fetchedObjects objectAtIndex:layoutUnit.dataIndex];
            [cell setCellHeight:[layoutUnit unitHeight]];
            
            WaterflowCardCell *waterflowCell = (WaterflowCardCell *)cell;
            
            waterflowCell.cardViewController.isWaterflowCard = YES;
            [waterflowCell.cardViewController configureCardWithStatus:targetStatus
                                                          imageHeight:layoutUnit.imageHeight
                                                            pageIndex:0
                                                          currentUser:self.currentUser
                                                   coreDataIdentifier:kCoreDataIdentifierDefault];
        }
        
    } else if(layoutUnit.unitType == UnitTypeDivider) {
        if (self.fetchedResultsController.fetchedObjects.count > layoutUnit.dataIndex) {
            Status *targetStatus = (Status*)[self.fetchedResultsController.fetchedObjects objectAtIndex:layoutUnit.dataIndex];
            [((WaterflowDividerCell *)cell).dividerViewController updateTimeInformation:targetStatus.createdAt];
        } 
    }
    
	return cell;
}

- (void)flowViewLoadMoreViews
{
    if (_hasMoreViews) {
        [self loadMoreData];
    }
}

- (int)numberOfObjectsInSection
{
    return self.fetchedResultsController.fetchedObjects.count;
}

- (CGFloat)heightForObjectAtIndex:(int)index_ withImageHeight:(NSInteger)imageHeight_
{
    if (self.fetchedResultsController.fetchedObjects.count > index_) {
        Status *status = (Status *)[self.fetchedResultsController.fetchedObjects objectAtIndex:index_];
        return [CardViewController heightForStatus:status andImageHeight:imageHeight_ timeStampEnabled:[NSUserDefaults isDateDisplayEnabled] picEnabled:[NSUserDefaults isPictureEnabled]];
    } else {
        return 0;
    }
}

#pragma mark - PostViewController Delegate

- (void)postViewController:(PostViewController *)vc willPostMessage:(NSString *)message {
    [vc dismissViewUpwards];
    _prevPostContent = message;
    
}

- (void)postViewController:(PostViewController *)vc didPostMessage:(NSString *)message {
    _prevPostContent = @"";
}

- (void)postViewController:(PostViewController *)vc didFailPostMessage:(NSString *)message {
    _postErrorIndicator.hidden = NO;
}

- (void)postViewController:(PostViewController *)vc willDropMessage:(NSString *)message {
    [vc dismissViewToRect:self.createStatusButton.frame];
    _prevPostContent = @"";
}

#pragma mark - Post recommand VCard weibo

- (void)postRecommandVCardWeibo {
    PostViewController *vc = [PostViewController getRecommendVCardNewStatusViewControllerWithDelegate:self];
    
    [vc showViewFromRect:self.createStatusButton.frame];
    
    [NSUserDefaults setShouldPostRecommendVCardWeibo:NO];
}

@end