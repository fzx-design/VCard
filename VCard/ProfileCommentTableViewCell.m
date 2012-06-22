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
#import "UIApplication+Addition.h"

@implementation ProfileCommentTableViewCell

@synthesize avatarImageView = _avatarImageView;
@synthesize baseCardBackgroundView = _baseCardBackgroundView;
@synthesize screenNameButton = _screenNameButton;
@synthesize commentButton = _commentButton;
@synthesize moreActionButton = _moreActionButton;


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

- (void)configureCellWithComment:(Comment *)comment_ isLastComment:(BOOL)isLast isFirstComment:(BOOL)isFirst
{
    self.comment = comment_;
    [CardViewController setStatusTextLabel:self.commentContentLabel withText:self.comment.text];
    [self.avatarImageView loadImageFromURL:self.comment.author.profileImageURL completion:nil];
    [self.avatarImageView setVerifiedType:[self.comment.author verifiedTypeOfUser]];
    
    //TODO: Add In_reply_to string
    NSString *screenName = @"";
    
    screenName = [NSString stringWithFormat:@"%@", self.comment.author.screenName];
    
    [self.screenNameButton setTitle:screenName forState:UIControlStateNormal];
    [self.screenNameButton setTitle:screenName forState:UIControlStateHighlighted];
    
    //Save the screen name
    [self.screenNameButton setTitle:self.comment.author.screenName forState:UIControlStateDisabled];
    
    CGFloat commentViewHeight = CardSizeTopViewHeight + CardSizeBottomViewHeight +
    CardSizeUserAvatarHeight + CardSizeTextGap + 
    self.commentContentLabel.frame.size.height;
    
    commentViewHeight += CardTailHeight;
    
    [self.baseCardBackgroundView resetHeight:commentViewHeight];
    [self.commentInfoView resetHeight:commentViewHeight];
    
    CGFloat cardTailOriginY = self.frame.size.height + CardTailOffset + 20.0;
    
    [self.timeStampLabel resetOriginY:cardTailOriginY];
    [self.timeStampLabel setText:[self.comment.createdAt stringRepresentation]];
    
    [self.downThreadImageView resetOriginY:cardTailOriginY + 30.0];
    
    self.upThreadImageView.hidden = isFirst;
    self.downThreadImageView.hidden = isLast;
}

- (IBAction)didClickCommentButton:(UIButton *)sender
{
    NSString *targetUserName = self.comment.author.screenName;
    NSString *targetStatusID = self.comment.targetStatus.statusID;
    CGRect frame = [self convertRect:sender.frame toView:[UIApplication sharedApplication].rootViewController.view];
    
    PostViewController *vc = [PostViewController getPostViewControllerViewWithType:PostViewControllerTypeComment
                                                                          delegate:self
                                                                           weiboID:targetStatusID
                                                                    weiboOwnerName:targetUserName];
    [vc showViewFromRect:frame];
}

#pragma mark - PostViewController Delegate

- (void)postViewController:(PostViewController *)vc willPostMessage:(NSString *)message {
    [vc dismissViewUpwards];
}

- (void)postViewController:(PostViewController *)vc didPostMessage:(NSString *)message {
    
}

- (void)postViewController:(PostViewController *)vc didFailPostMessage:(NSString *)message {
    
}

- (void)postViewController:(PostViewController *)vc willDropMessage:(NSString *)message {
    if(vc.type == PostViewControllerTypeComment)
        [vc dismissViewToRect:[self convertRect:self.commentButton.frame toView:[UIApplication sharedApplication].rootViewController.view]];
    else
        [vc dismissViewToRect:[self convertRect:self.moreActionButton.frame toView:[UIApplication sharedApplication].rootViewController.view]];
}

@end
