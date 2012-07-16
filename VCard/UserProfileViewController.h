//
//  UserProfileViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-5-28.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "StackViewPageController.h"
#import "ProfileRelationTableViewController.h"
#import "ProfileStatusTableViewController.h"
#import "BaseStackLayoutView.h"
#import "UserAvatarImageView.h"

@interface UserProfileViewController : StackViewPageController {
    
    User *_user;
    ProfileRelationTableViewController *_friendController;
    ProfileRelationTableViewController *_followerController;
    ProfileStatusTableViewController *_statusController;
}

@property (nonatomic, strong) NSString *screenName;
@property (nonatomic, weak) IBOutlet UserAvatarImageView *avatarImageView;

@property (nonatomic, weak) IBOutlet UILabel *screenNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
@property (nonatomic, weak) IBOutlet UITextView *discriptionLabel;
@property (nonatomic, weak) IBOutlet UITextView *discriptionShadowLabel;
@property (nonatomic, weak) IBOutlet UILabel *statusCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *friendCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *followerCountLabel;
@property (nonatomic, weak) IBOutlet UIButton *checkStatusesButton;
@property (nonatomic, weak) IBOutlet UIButton *checkFriendsButton;
@property (nonatomic, weak) IBOutlet UIButton *checkFollowersButton;

@property (nonatomic, weak) IBOutlet UIImageView *genderImageView;

@property (nonatomic, strong) User *user;

@property (nonatomic, strong) ProfileRelationTableViewController *friendController;
@property (nonatomic, strong) ProfileRelationTableViewController *followerController;
@property (nonatomic, strong) ProfileStatusTableViewController *statusController;

- (void)setUpViews;
- (IBAction)showFollowers:(id)sender;
- (IBAction)showFriends:(id)sender;
- (IBAction)showStatuses:(id)sender;

@end
