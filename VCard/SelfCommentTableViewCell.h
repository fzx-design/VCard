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
#import "RefreshableCoreDataTableViewController.h"

@interface SelfCommentTableViewCell : UITableViewCell <PostViewControllerDelegate, TTTAttributedLabelDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UserAvatarImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet BaseCardBackgroundView *baseCardBackgroundView;
@property (nonatomic, weak) IBOutlet UIButton *screenNameButton;
@property (nonatomic, weak) IBOutlet UILabel *screenNameLabel;
@property (nonatomic, weak) IBOutlet UIButton *commentButton;
@property (nonatomic, weak) IBOutlet UIButton *moreActionButton;
@property (nonatomic, weak) IBOutlet UIButton *viewDetailButton;
@property (nonatomic, weak) IBOutlet UIView *commentInfoView;
@property (nonatomic, weak) IBOutlet TTTAttributedLabel *commentContentLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeStampLabel;
@property (nonatomic, weak) Comment *comment;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, weak) id<CommentTableViewCellDelegate> delegate;

- (IBAction)didClickCommentButton:(UIButton *)sender;
- (IBAction)didClickUserNameButton:(UIButton *)sender;
- (IBAction)didClickViewDetailButton:(UIButton *)sender;
- (IBAction)didClickMoreActionButton:(UIButton *)sender;
- (void)configureCellWithComment:(Comment *)comment;

@end
