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

@interface ProfileCommentTableViewCell : UITableViewCell {
    UserAvatarImageView *_avatarImageView;
    BaseCardBackgroundView *_baseCardBackgroundView;
    
    UIButton *_screenNameButton;
    UIButton *_commentButton;
    UIButton *_moreActionButton;
    UIImageView *_leftThreadImageView;
    UIImageView *_rightThreadImageView;
}

@property (nonatomic, strong) IBOutlet UserAvatarImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet BaseCardBackgroundView *baseCardBackgroundView;
@property (nonatomic, strong) IBOutlet UIButton *screenNameButton;
@property (nonatomic, strong) IBOutlet UIButton *commentButton;
@property (nonatomic, strong) IBOutlet UIButton *moreActionButton;
@property (nonatomic, strong) IBOutlet UIImageView *leftThreadImageView;
@property (nonatomic, strong) IBOutlet UIImageView *rightThreadImageView;

@property (nonatomic, strong) IBOutlet UIView *commentInfoView;
@property (nonatomic, strong) IBOutlet TTTAttributedLabel *commentContentLabel;
@property (nonatomic, strong) IBOutlet UILabel *timeStampLabel;

- (void)configureCellWithComment:(Comment *)comment;

@end
