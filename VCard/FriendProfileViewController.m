//
//  FriendProfileViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-5-28.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "FriendProfileViewController.h"

@interface FriendProfileViewController ()

@end

@implementation FriendProfileViewController

@synthesize avatarImageView = _avatarImageView;
@synthesize screenLabel = _screenLabel;
@synthesize locationLabel = _locationLabel;
@synthesize discriptionLabel = _discriptionLabel;
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
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark - Properties
- (ProfileRelationTableViewController *)friendController
{
    if (!_friendController) {
        _friendController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileRelationTableViewController"];
        _friendController.view.frame = CGRectMake(23.0, 320.0, 384.0, self.view.frame.size.height);
        _friendController.user = self.currentUser;
        _friendController.type = RelationshipViewTypeFriends;
    }
    return _friendController;
}

- (ProfileRelationTableViewController *)followerController
{
    if (!_followerController) {
        _followerController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileRelationTableViewController"];
        _followerController.view.frame = CGRectMake(23.0, 320.0, 384.0, self.view.frame.size.height);
        _followerController.user = self.currentUser;
        _friendController.type = RelationshipViewTypeFollowers;
    }
    return _followerController;
}

@end
