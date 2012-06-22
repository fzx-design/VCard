//
//  ProfileCommentTableViewCell.m
//  VCard
//
//  Created by 海山 叶 on 12-6-1.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "ProfileCommentTableViewCell.h"
#import "CardViewController.h"
#import "NSDateAddition.h"
#import "UIView+Resize.h"
#import "User.h"

@implementation ProfileCommentTableViewCell

@synthesize avatarImageView = _avatarImageView;
@synthesize baseCardBackgroundView = _baseCardBackgroundView;
@synthesize screenNameButton = _screenNameButton;
@synthesize commentButton = _commentButton;
@synthesize moreActionButton = _moreActionButton;
@synthesize leftThreadImageView = _leftThreadImageView;
@synthesize rightThreadImageView = _rightThreadImageView;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCellWithComment:(Comment *)comment
{
    
    [CardViewController setStatusTextLabel:self.commentContentLabel withText:comment.text];
    [self.avatarImageView loadImageFromURL:comment.author.profileImageURL completion:nil];
    [self.avatarImageView setVerifiedType:[comment.author verifiedTypeOfUser]];
    
    //TODO: Add In_reply_to string
    NSString *screenName = @"";
    
    screenName = [NSString stringWithFormat:@"%@", comment.author.screenName];
    
    [self.screenNameButton setTitle:screenName forState:UIControlStateNormal];
    [self.screenNameButton setTitle:screenName forState:UIControlStateHighlighted];
    
    //Save the screen name
    [self.screenNameButton setTitle:comment.author.screenName forState:UIControlStateDisabled];
    
    CGFloat commentViewHeight = CardSizeTopViewHeight + CardSizeBottomViewHeight +
    CardSizeUserAvatarHeight + CardSizeTextGap + 
    self.commentContentLabel.frame.size.height;
    
    commentViewHeight += CardTailHeight;
    
    [self.baseCardBackgroundView resetHeight:commentViewHeight];
    [self.commentInfoView resetHeight:commentViewHeight];
    
    CGFloat cardTailOriginY = self.frame.size.height + CardTailOffset + 20.0;
    
    [self.timeStampLabel resetOriginY:cardTailOriginY];
    [self.timeStampLabel setText:[comment.createdAt stringRepresentation]];
}

@end
