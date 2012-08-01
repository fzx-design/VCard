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
#import "NSDate+Addition.h"
#import "UIApplication+Addition.h"
#import "UserAccountManager.h"
#import "WBClient.h"
#import "InnerBrowserViewController.h"
#import "TTTAttributedLabelConfiguer.h"

#define kActionSheetViewCopyIndex   0
#define kActionSheetViewDelete      1

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
    [TTTAttributedLabelConfiguer setCardViewController:nil StatusTextLabel:self.commentContentLabel withText:self.comment.text];
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
    NSString *targetUserName = self.comment.author.screenName;
    NSString *targetStatusID = self.comment.targetStatus.statusID;
    NSString *targetReplyID = self.comment.commentID;
    CGRect frame = [self convertRect:sender.frame toView:[UIApplication sharedApplication].rootViewController.view];
    
    PostViewController *vc = [PostViewController getCommentReplyViewControllerWithWeiboID:targetStatusID replyID:targetReplyID weiboOwnerName:targetUserName delegate:self];
    [vc showViewFromRect:frame];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldShowCommentList
                                                        object:@{kNotificationObjectKeyIndex: indexString,
                                                                kNotificationObjectKeyStatus: status}];
}

- (IBAction)didClickMoreActionButton:(UIButton *)sender
{
    NSString *deleteTitle = [self.comment.author isEqualToUser:[CoreDataViewController getCurrentUser]] ? @"删除" : nil;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self 
                                                    cancelButtonTitle:nil 
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"复制评论", deleteTitle, nil];
    actionSheet.destructiveButtonIndex = kActionSheetViewDelete;
    actionSheet.delegate = self;
    [actionSheet showFromRect:sender.bounds inView:sender animated:YES];
}

#pragma mark - TTTAttributedLabel Delegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)userName
{
    [self sendUserNameClickedNotificationWithName:userName];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithQuate:(NSString *)quate
{
    [self sendShowTopicNotification:quate];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    [InnerBrowserViewController loadLinkWithURL:url];
}

- (void)sendUserNameClickedNotificationWithName:(NSString *)userName
{
    if (userName) {
        NSString *indexString = [NSString stringWithFormat:@"%i", self.pageIndex];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldShowUserByName
                                                            object:@{kNotificationObjectKeyUserName: userName,
                                       kNotificationObjectKeyIndex: indexString}];
    }
}

- (void)sendShowTopicNotification:(NSString *)searchKey
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldShowTopic object:@{kNotificationObjectKeySearchKey: searchKey, kNotificationObjectKeyIndex: [NSString stringWithFormat:@"%i", self.pageIndex]}];
}


#pragma mark - PostViewController Delegate

- (void)postViewController:(PostViewController *)vc willPostMessage:(NSString *)message {
    [vc dismissViewUpwards];
}

- (void)postViewController:(PostViewController *)vc didPostMessage:(NSString *)message {
    [_delegate commentTableViewCellDidComment];
}

- (void)postViewController:(PostViewController *)vc didFailPostMessage:(NSString *)message {
    
}

- (void)postViewController:(PostViewController *)vc willDropMessage:(NSString *)message {
    if(vc.type == PostViewControllerTypeRepost)
        [vc dismissViewToRect:[self convertRect:self.moreActionButton.frame toView:[UIApplication sharedApplication].rootViewController.view]];
    else
        [vc dismissViewToRect:[self convertRect:self.commentButton.frame toView:[UIApplication sharedApplication].rootViewController.view]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == kActionSheetViewCopyIndex) {
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        [pb setString:self.comment.text];
    } else if(buttonIndex == kActionSheetViewDelete) {
        [self deleteComment];
    }
}

- (void)deleteComment
{
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldDeleteComment
                                                                object:self.comment.commentID];
        } else {
            //TODO: Handle Error
        }
    }];
    
    [client deleteComment:self.comment.commentID];
}

@end
