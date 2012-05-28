//
//  FriendProfileViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-5-28.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "StackViewPageController.h"
#import "ProfileRelationTableViewController.h"
#import "UserAvatarImageView.h"
#import "User.h"

@interface FriendProfileViewController : StackViewPageController {
    UserAvatarImageView *_avatarImageView;
    UILabel *_screenLabel;
    UILabel *_locationLabel;
    UILabel *_discriptionLabel;
    UILabel *_statusCountLabel;
    UILabel *_friendCountLabel;
    UILabel *_followerCountLabel;
    
    UIButton *_changeAvatarButton;
    UIButton *_checkCommentButton;
    UIButton *_checkMentionButton;
    UIButton *_checkStatusesButton;
    UIButton *_checkFriendsButton;
    UIButton *_checkFollowersButton;
        
    User *_user;
    ProfileRelationTableViewController *_friendController;
    ProfileRelationTableViewController *_followerController;
}

@property (nonatomic, strong) IBOutlet UserAvatarImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet UILabel *screenLabel;
@property (nonatomic, strong) IBOutlet UILabel *locationLabel;
@property (nonatomic, strong) IBOutlet UILabel *discriptionLabel;
@property (nonatomic, strong) IBOutlet UILabel *statusCountLabel;
@property (nonatomic, strong) IBOutlet UILabel *friendCountLabel;
@property (nonatomic, strong) IBOutlet UILabel *followerCountLabel;
@property (nonatomic, strong) IBOutlet UIButton *changeAvatarButton;
@property (nonatomic, strong) IBOutlet UIButton *checkCommentButton;
@property (nonatomic, strong) IBOutlet UIButton *checkMentionButton;
@property (nonatomic, strong) IBOutlet UIButton *checkStatusesButton;
@property (nonatomic, strong) IBOutlet UIButton *checkFriendsButton;
@property (nonatomic, strong) IBOutlet UIButton *checkFollowersButton;

@property (nonatomic, strong) User *user;

@property (nonatomic, strong) ProfileRelationTableViewController *friendController;
@property (nonatomic, strong) ProfileRelationTableViewController *followerController;

@end
