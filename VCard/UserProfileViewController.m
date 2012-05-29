//
//  UserProfileViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-5-28.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "UserProfileViewController.h"
#import "UIView+Resize.h"
#import "User.h"

@interface UserProfileViewController ()

@end

@implementation UserProfileViewController

@synthesize testButton;

@synthesize screenName;
@synthesize avatarImageView = _avatarImageView;
@synthesize backgroundView = _backgroundView;
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
	
}

- (void)setUpViews
{
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (IBAction)createNewStackPage:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameAddNewStackPage object:self];
}

- (IBAction)showFollowers:(id)sender
{
    self.checkFollowersButton.selected = YES;
    self.checkStatusesButton.selected = NO;
    self.checkFriendsButton.selected = NO;
    [self.backgroundView addSubview:self.followerController.view];
    [self.friendController.view removeFromSuperview];
}

- (IBAction)showFriends:(id)sender
{
    self.checkFollowersButton.selected = NO;
    self.checkStatusesButton.selected = NO;
    self.checkFriendsButton.selected = YES;
    [self.backgroundView addSubview:self.friendController.view];
    [self.followerController.view removeFromSuperview];
}

- (CGRect)frameForTableView
{
    CGFloat originY = self.checkStatusesButton.frame.origin.y + self.checkStatusesButton.frame.size.height;
    CGFloat height = self.view.frame.size.height - originY;
    return CGRectMake(24.0, originY, 382.0, height);
}

#pragma mark - Properties
- (ProfileRelationTableViewController *)friendController
{
    if (!_friendController) {
        _friendController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileRelationTableViewController"];
        _friendController.view.frame = [self frameForTableView];
        _friendController.user = self.user;
        _friendController.type = RelationshipViewTypeFriends;
        _friendController.stackPageIndex = self.pageIndex;
    }
    return _friendController;
}

- (ProfileRelationTableViewController *)followerController
{
    if (!_followerController) {
        _followerController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileRelationTableViewController"];
        _followerController.view.frame = [self frameForTableView];
        _followerController.user = self.user;
        _followerController.type = RelationshipViewTypeFollowers;
        _followerController.stackPageIndex = self.pageIndex;
    }
    return _followerController;
}


@end
