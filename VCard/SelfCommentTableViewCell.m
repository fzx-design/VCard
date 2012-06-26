//
//  SelfCommentTableViewCell.m
//  VCard
//
//  Created by Gabriel Yeah on 12-6-24.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "SelfCommentTableViewCell.h"
#import "CardViewController.h"
#import "User.h"
#import "UIView+Resize.h"
#import "NSDateAddition.h"
#import "UIApplication+Addition.h"

@implementation SelfCommentTableViewCell

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

- (void)configureCellWithComment:(Comment *)comment_
{
    self.comment = comment_;
    self.commentContentLabel.delegate = self;
    [CardViewController setStatusTextLabel:self.commentContentLabel withText:self.comment.text];
    [self.avatarImageView loadImageFromURL:self.comment.author.profileImageURL completion:nil];
    [self.avatarImageView setVerifiedType:[self.comment.author verifiedTypeOfUser]];
    
    //TODO: Add In_reply_to string
    NSString *screenName = @"";
    
    screenName = [NSString stringWithFormat:@"%@", self.comment.author.screenName];
    
    [self.screenNameLabel setText:screenName];
    
    //Save the screen name
    [self.screenNameButton setTitle:self.comment.author.screenName forState:UIControlStateDisabled];
    
    CGFloat commentViewHeight = CardSizeTopViewHeight + CardSizeBottomViewHeight +
    CardSizeUserAvatarHeight + CardSizeTextGap + 
    self.commentContentLabel.frame.size.height;
    
    commentViewHeight += CardTailHeight;
    
    [self.baseCardBackgroundView resetHeight:commentViewHeight];
    [self.commentInfoView resetHeight:commentViewHeight];
    
    CGFloat cardTailOriginY = self.frame.size.height + CardTailOffset - 4.0;
    
    [self.timeStampLabel resetOriginY:cardTailOriginY];
    [self.timeStampLabel setText:[self.comment.createdAt stringRepresentation]];
}


#pragma mark - IBActions

- (IBAction)didClickCommentButton:(UIButton *)sender
{
//    NSString *targetUserName = self.comment.author.screenName;
//    NSString *targetStatusID = self.comment.targetStatus.statusID;
//    CGRect frame = [self convertRect:sender.frame toView:[UIApplication sharedApplication].rootViewController.view];
}

- (IBAction)didClickUserNameButton:(UIButton *)sender
{
    NSString *userName = [sender titleForState:UIControlStateDisabled];
    [self sendUserNameClickedNotificationWithName:userName];
}

- (IBAction)didClickViewDetailButton:(UIButton *)sender
{
    Status *status = self.comment.targetStatus;
    NSString *indexString = [NSString stringWithFormat:@"%i", self.pageIndex];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCommentButtonClicked
                                                        object:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                status, kNotificationObjectKeyStatus,
                                                                indexString, kNotificationObjectKeyIndex, nil]];
}

#pragma mark - TTTAttributedLabel Delegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)userName
{
    [self sendUserNameClickedNotificationWithName:userName];
}

- (void)sendUserNameClickedNotificationWithName:(NSString *)userName
{
    NSString *indexString = [NSString stringWithFormat:@"%i", self.pageIndex];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameUserNameClicked
                                                        object:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                userName, kNotificationObjectKeyUserName,
                                                                indexString, kNotificationObjectKeyIndex, nil]];
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
    if(vc.type == PostViewControllerTypeRepost)
        [vc dismissViewToRect:[self convertRect:self.moreActionButton.frame toView:[UIApplication sharedApplication].rootViewController.view]];
    else
        [vc dismissViewToRect:[self convertRect:self.commentButton.frame toView:[UIApplication sharedApplication].rootViewController.view]];
}

@end
