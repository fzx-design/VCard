//
//  UserProfileViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-5-28.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "UserProfileViewController.h"
#import "UIApplication+Addition.h"
#import "UIView+Resize.h"
#import "User.h"

@interface UserProfileViewController ()

@end

@implementation UserProfileViewController

@synthesize screenName;
@synthesize avatarImageView = _avatarImageView;
@synthesize screenNameLabel = _screenNameLabel;
@synthesize locationLabel = _locationLabel;
@synthesize discriptionLabel = _discriptionLabel;
@synthesize discriptionShadowLabel = _discriptionShadowLabel;
@synthesize statusCountLabel = _statusCountLabel;
@synthesize friendCountLabel = _friendCountLabel;
@synthesize followerCountLabel = _followerCountLabel;
@synthesize checkStatusesButton = _checkStatusesButton;
@synthesize checkFriendsButton = _checkFriendsButton;
@synthesize checkFollowersButton = _checkFollowersButton;

@synthesize genderImageView = _genderImageView;

@synthesize user = _user;
@synthesize friendController = _friendController;
@synthesize followerController = _followerController;
@synthesize statusController = _statusController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Over Load Method
- (void)initialLoad
{
//    self.pageType = StackViewPageTypeUser;
//    self.pageDescription = self.user.screenName;
}

- (void)stackScrolling:(CGFloat)speed
{
    //TODO: Test
    CGFloat angle = -0.089 * speed / 20;
    [_avatarImageView swingOnceThenHalt:_avatarImageView.layer angle:angle * M_PI];
}

- (void)stackScrollingStart
{
    //TODO: Test
    [_avatarImageView swingOnceThenHalt:_avatarImageView.layer angle:-0.089 * M_PI];
}

- (void)stackScrollingEnd
{
    //TODO: Test
    [_avatarImageView swingHalt:_avatarImageView.layer fromAngle:-0.089 * M_PI];
}

- (void)enableScrollToTop
{
    [super enableScrollToTop];
    self.statusController.tableView.scrollsToTop = YES;
}

- (void)disableScrollToTop
{
    [super disableScrollToTop];
    self.statusController.tableView.scrollsToTop = NO;
    self.friendController.tableView.scrollsToTop = NO;
    self.followerController.tableView.scrollsToTop = NO;
}

- (void)pagePopedFromStack
{
    
}

- (void)refresh
{
    if (self.checkFollowersButton.selected) {
        [self.followerController refresh];
    } else if(self.checkFriendsButton.selected) {
        [self.friendController refresh];
    } else {
        [self.statusController refresh];
    }
}


#pragma mark - Setup
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self setCheckButtonEnabled:NO];
    [self.topShadowImageView resetOrigin:[self frameForTableView].origin];
    [self.backgroundView addSubview:self.topShadowImageView];
}

- (void)setUpViews
{
    [self.statusController refresh];
    
    self.view.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    [_avatarImageView loadImageFromURL:self.user.largeAvatarURL completion:nil];
    [_avatarImageView setVerifiedType:[self.user verifiedTypeOfUser]];
    
    [_screenNameLabel setText:self.user.screenName];
    [_locationLabel setText:self.user.location];
    [_discriptionLabel setText:self.user.selfDescription];
    [_discriptionShadowLabel setText:self.user.selfDescription];
    [_statusCountLabel setText:self.user.statusesCount];
    [_friendCountLabel setText:self.user.friendsCount];
    [_followerCountLabel setText:self.user.followersCount];
    
    NSString *genderImage = [self.user.gender isEqualToString:@"f"] ? kRLIconFemale : kRLIconMale;
    UIImage *image = [UIImage imageNamed:genderImage];
    [_genderImageView setImage:image];
    
    [self.view resetWidth:384.0];
    [self.backgroundView resetWidth:431.0];
    
//    [self showStatuses:nil];
    
    [self setCheckButtonEnabled:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)setCheckButtonEnabled:(BOOL)enabled
{
    _checkFollowersButton.userInteractionEnabled = enabled;
    _checkFriendsButton.userInteractionEnabled = enabled;
    _checkStatusesButton.userInteractionEnabled = enabled;
}

- (IBAction)showFollowers:(id)sender
{
    self.checkFollowersButton.selected = YES;
    self.checkStatusesButton.selected = NO;
    self.checkFriendsButton.selected = NO;
    [self.backgroundView insertSubview:self.followerController.view belowSubview:self.topShadowImageView];
    self.followerController.tableView.scrollsToTop = YES;
    if (_statusController) {
        [self.statusController.view removeFromSuperview];
        self.statusController.tableView.scrollsToTop = NO;
    }
    if (_friendController) {
        [self.friendController.view removeFromSuperview];
        self.friendController.tableView.scrollsToTop = NO;
    }
}

- (IBAction)showFriends:(id)sender
{
    self.checkFollowersButton.selected = NO;
    self.checkStatusesButton.selected = NO;
    self.checkFriendsButton.selected = YES;
    [self.backgroundView insertSubview:self.friendController.view belowSubview:self.topShadowImageView];
    self.friendController.tableView.scrollsToTop = YES;    
    if (_statusController) {
        [self.statusController.view removeFromSuperview];
        self.statusController.tableView.scrollsToTop = NO;
    }
    if (_followerController) {
        [self.followerController.view removeFromSuperview];
        self.followerController.tableView.scrollsToTop = NO;
    }
}

- (IBAction)showStatuses:(id)sender
{
    self.checkFollowersButton.selected = NO;
    self.checkStatusesButton.selected = YES;
    self.checkFriendsButton.selected = NO;
    [self.backgroundView insertSubview:self.statusController.view belowSubview:self.topShadowImageView];
    self.statusController.tableView.scrollsToTop = YES;
    if (_followerController) {
        [self.followerController.view removeFromSuperview];
        self.followerController.tableView.scrollsToTop = NO;
    }
    if (_friendController) {
        [self.friendController.view removeFromSuperview];
        self.friendController.tableView.scrollsToTop = NO;
    }
}

- (CGRect)frameForTableView
{
    CGFloat originY = self.checkStatusesButton.frame.origin.y + self.checkStatusesButton.frame.size.height;
    CGFloat height = [UIApplication heightExcludingTopBar] - originY;
    return CGRectMake(24.0, originY, 382.0, height);
}

#pragma mark - Properties
- (ProfileRelationTableViewController *)friendController
{
    if (!_friendController) {
        _friendController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileRelationTableViewController"];
        _friendController.view.frame = [self frameForTableView];
        _friendController.tableView.frame = [self frameForTableView];
        _friendController.user = self.user;
        _friendController.type = RelationshipViewTypeFriends;
        _friendController.pageIndex = self.pageIndex;
        [_friendController refresh];
    }
    return _friendController;
}

- (ProfileRelationTableViewController *)followerController
{
    if (!_followerController) {
        _followerController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileRelationTableViewController"];
        _followerController.view.frame = [self frameForTableView];
        _followerController.tableView.frame = [self frameForTableView];
        _followerController.user = self.user;
        _followerController.type = RelationshipViewTypeFollowers;
        _followerController.pageIndex = self.pageIndex;
        [_followerController refresh];
    }
    return _followerController;
}

- (ProfileStatusTableViewController *)statusController
{
    if (!_statusController) {
        _statusController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileStatusTableViewController"];
        _statusController.type = StatusTableViewControllerTypeUserStatus;
        _statusController.user = self.user;
        _statusController.currentUser = self.currentUser;
        _statusController.pageIndex = self.pageIndex;
        _statusController.view.frame = [self frameForTableView];
        _statusController.tableView.frame = [self frameForTableView];
    }
    return _statusController;
}

@end
