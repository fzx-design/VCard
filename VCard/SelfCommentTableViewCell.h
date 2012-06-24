//
//  SelfCommentTableViewCell.h
//  VCard
//
//  Created by Gabriel Yeah on 12-6-24.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserAvatarImageView.h"
#import "BaseCardBackgroundView.h"
#import "TTTAttributedLabel.h"
#import "Comment.h"
#import "PostViewController.h"

@interface SelfCommentTableViewCell : UITableViewCell <PostViewControllerDelegate, TTTAttributedLabelDelegate>

@property (nonatomic, strong) IBOutlet UserAvatarImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet BaseCardBackgroundView *baseCardBackgroundView;
@property (nonatomic, strong) IBOutlet UIButton *screenNameButton;
@property (nonatomic, strong) IBOutlet UIButton *commentButton;
@property (nonatomic, strong) IBOutlet UIButton *moreActionButton;
@property (nonatomic, strong) IBOutlet UIButton *viewDetailButton;
@property (nonatomic, strong) IBOutlet UIView *commentInfoView;
@property (nonatomic, strong) IBOutlet TTTAttributedLabel *commentContentLabel;
@property (nonatomic, strong) IBOutlet UILabel *timeStampLabel;
@property (nonatomic, weak) Comment *comment;
@property (nonatomic, assign) NSInteger pageIndex;

- (IBAction)didClickCommentButton:(UIButton *)sender;
- (IBAction)didClickUserNameButton:(UIButton *)sender;
- (IBAction)didClickViewDetailButton:(UIButton *)sender;
- (void)configureCellWithComment:(Comment *)comment;

@end
