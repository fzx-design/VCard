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
    UserAvatarImageView *_avatarImageView;
    
    UILabel *_screenNameLabel;
    UILabel *_locationLabel;
    UITextView *_discriptionLabel;
    UITextView *_discriptionShadowLabel;
    UILabel *_statusCountLabel;
    UILabel *_friendCountLabel;
    UILabel *_followerCountLabel;
    
    UIButton *_checkStatusesButton;
    UIButton *_checkFriendsButton;
    UIButton *_checkFollowersButton;
    
    UIImageView *_genderImageView;
    
    
    User *_user;
    ProfileRelationTableViewController *_friendController;
    ProfileRelationTableViewController *_followerController;
    ProfileStatusTableViewController *_statusController;
}

@property (nonatomic, strong) NSString *screenName;
@property (nonatomic, strong) IBOutlet UserAvatarImageView *avatarImageView;

@property (nonatomic, strong) IBOutlet UILabel *screenNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *locationLabel;
@property (nonatomic, strong) IBOutlet UITextView *discriptionLabel;
@property (nonatomic, strong) IBOutlet UITextView *discriptionShadowLabel;
@property (nonatomic, strong) IBOutlet UILabel *statusCountLabel;
@property (nonatomic, strong) IBOutlet UILabel *friendCountLabel;
@property (nonatomic, strong) IBOutlet UILabel *followerCountLabel;
@property (nonatomic, strong) IBOutlet UIButton *checkStatusesButton;
@property (nonatomic, strong) IBOutlet UIButton *checkFriendsButton;
@property (nonatomic, strong) IBOutlet UIButton *checkFollowersButton;

@property (nonatomic, strong) IBOutlet UIImageView *genderImageView;

@property (nonatomic, strong) User *user;

@property (nonatomic, strong) ProfileRelationTableViewController *friendController;
@property (nonatomic, strong) ProfileRelationTableViewController *followerController;
@property (nonatomic, strong) ProfileStatusTableViewController *statusController;

- (void)setUpViews;
- (IBAction)showFollowers:(id)sender;
- (IBAction)showFriends:(id)sender;
- (IBAction)showStatuses:(id)sender;

@end
