//
//  ProfileCommentTableViewCell.h
//  VCard
//
//  Created by 海山 叶 on 12-6-1.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserAvatarImageView.h"
#import "BaseCardBackgroundView.h"
#import "TTTAttributedLabel.h"
#import "Comment.h"
#import "PostViewController.h"
#import <MessageUI/MessageUI.h>

@interface ProfileCommentTableViewCell : UITableViewCell <PostViewControllerDelegate, TTTAttributedLabelDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
    UserAvatarImageView *_avatarImageView;
    BaseCardBackgroundView *_baseCardBackgroundView;
    
    UIButton *_screenNameButton;
    UIButton *_commentButton;
    UIButton *_moreActionButton;
}

@property (nonatomic, strong) IBOutlet UserAvatarImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet BaseCardBackgroundView *baseCardBackgroundView;
@property (nonatomic, strong) IBOutlet UIButton *screenNameButton;
@property (nonatomic, strong) IBOutlet UILabel *screenNameLabel;
@property (nonatomic, strong) IBOutlet UIButton *commentButton;
@property (nonatomic, strong) IBOutlet UIButton *moreActionButton;
@property (nonatomic, strong) IBOutlet UIImageView *upThreadImageView;
@property (nonatomic, strong) IBOutlet UIImageView *downThreadImageView;
@property (nonatomic, strong) IBOutlet UIView *commentInfoView;
@property (nonatomic, strong) IBOutlet TTTAttributedLabel *commentContentLabel;
@property (nonatomic, strong) IBOutlet UILabel *timeStampLabel;
@property (nonatomic, weak) Comment *comment;
@property (nonatomic, weak) Status *status;
@property (nonatomic, assign) NSInteger pageIndex;

- (IBAction)didClickCommentButton:(UIButton *)sender;
- (IBAction)didClickUserNameButton:(UIButton *)sender;
- (IBAction)didClickMoreActionButton:(UIButton *)sender;

- (void)configureCellWithComment:(Comment *)comment
                   isLastComment:(BOOL)isLast
                  isFirstComment:(BOOL)isFirst;
- (void)configureCellWithStatus:(Status *)status;
- (void)updateThreadStatus:(BOOL)isLast;

@end
