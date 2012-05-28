//
//  UserProfileViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-5-28.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "UserProfileViewController.h"
#import "User.h"

@interface UserProfileViewController ()

@end

@implementation UserProfileViewController

@synthesize testButton;

@synthesize avatarImageView = _avatarImageView;
@synthesize backgroundView = _backgroundView;
@synthesize screenNameLabel = _screenNameLabel;
@synthesize locationLabel = _locationLabel;
@synthesize discriptionLabel = _discriptionLabel;
@synthesize discriptionShadowLabel = _discriptionShadowLabel;
@synthesize statusCountLabel = _statusCountLabel;
@synthesize friendCountLabel = _friendCountLabel;
@synthesize followerCountLabel = _followerCountLabel;
@synthesize changeAvatarButton = _changeAvatarButton;
@synthesize checkCommentButton = _checkCommentButton;
@synthesize checkMentionButton = _checkMentionButton;
@synthesize checkStatusesButton = _checkStatusesButton;
@synthesize checkFriendsButton = _checkFriendsButton;
@synthesize checkFollowersButton = _checkFollowersButton;

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
	[_avatarImageView loadImageFromURL:self.currentUser.largeAvatarURL completion:nil];
    [_screenNameLabel setText:self.currentUser.screenName];
    [_locationLabel setText:self.currentUser.location];
    [_discriptionLabel setText:self.currentUser.selfDescription];
    [_discriptionShadowLabel setText:self.currentUser.selfDescription];
    [_statusCountLabel setText:self.currentUser.statusesCount];
    [_friendCountLabel setText:self.currentUser.friendsCount];
    [_followerCountLabel setText:self.currentUser.followersCount];
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
    self.checkFollowersButton.highlighted = YES;
    self.checkStatusesButton.highlighted = NO;
    self.checkFriendsButton.highlighted = NO;
    [self.backgroundView addSubview:self.followerController.view];
    [self.friendController.view removeFromSuperview];
}

- (IBAction)showFriends:(id)sender
{
    self.checkFollowersButton.highlighted = NO;
    self.checkStatusesButton.highlighted = NO;
    self.checkFriendsButton.highlighted = YES;
    [self.backgroundView addSubview:self.friendController.view];
    [self.followerController.view removeFromSuperview];
}

- (CGRect)frameForTableView
{
    CGFloat height = self.view.frame.size.height - 316.0;
    return CGRectMake(25.0, 316.0, 382.0, height);
}

#pragma mark - Properties
- (ProfileRelationTableViewController *)friendController
{
    if (!_friendController) {
        _friendController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileRelationTableViewController"];
        _friendController.view.frame = [self frameForTableView];
        _friendController.user = self.currentUser;
        _friendController.type = RelationshipViewTypeFriends;
    }
    return _friendController;
}

- (ProfileRelationTableViewController *)followerController
{
    if (!_followerController) {
        _followerController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileRelationTableViewController"];
        _followerController.view.frame = [self frameForTableView];
        _followerController.user = self.currentUser;
        _followerController.type = RelationshipViewTypeFollowers;
    }
    return _followerController;
}


@end
