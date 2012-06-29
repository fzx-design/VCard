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
#import "UserAccountManager.h"
#import "WBClient.h"

#define kActionSheetCommentCopyIndex   0
#define kActionSheetCommentDelete      1

#define kActionSheetStatusRepostIndex     0
#define kActionSheetStatusFavorIndex      1
#define kActionSheetStatusCopyIndex       2
#define kActionSheetStatusShareIndex      3
#define kActionSheetStatusDeleteIndex     4

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

- (void)configureCellWithStatus:(Status *)status
{
    self.status = status;
    self.commentContentLabel.delegate = self;
    [CardViewController setStatusTextLabel:self.commentContentLabel withText:self.status.text];
    [self.avatarImageView loadImageFromURL:self.status.author.profileImageURL completion:nil];
    [self.avatarImageView setVerifiedType:[self.status.author verifiedTypeOfUser]];
    
    //TODO: Add In_reply_to string
    NSString *screenName = @"";
    
    screenName = [NSString stringWithFormat:@"%@ 转发并评论", self.status.author.screenName];
    
    [self.screenNameLabel setText:screenName];
    
    //Save the screen name
    [self.screenNameButton setTitle:self.status.author.screenName forState:UIControlStateDisabled];
    
    CGFloat commentViewHeight = CardSizeTopViewHeight + CardSizeBottomViewHeight +
    CardSizeUserAvatarHeight + CardSizeTextGap + 
    self.commentContentLabel.frame.size.height;
    commentViewHeight += CardTailHeight;
    
    [self.baseCardBackgroundView resetHeight:commentViewHeight];
    [self.commentInfoView resetHeight:commentViewHeight];
    
    CGFloat cardTailOriginY = self.frame.size.height + CardTailOffset - 4.0;
    
    [self.timeStampLabel resetOriginY:cardTailOriginY];
    [self.timeStampLabel setText:[self.status.createdAt stringRepresentation]];
        
    self.upThreadImageView.hidden = YES;
    self.downThreadImageView.hidden = YES;
}

- (void)configureCellWithComment:(Comment *)comment_ isLastComment:(BOOL)isLast isFirstComment:(BOOL)isFirst
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
    
    [self.downThreadImageView resetOriginY:cardTailOriginY + 30.0];
    
    self.upThreadImageView.hidden = isFirst;
    self.downThreadImageView.hidden = isLast;
}

- (void)updateThreadStatusIsFirst:(BOOL)isFirst isLast:(BOOL)isLast
{
    self.downThreadImageView.hidden = isLast;
    self.upThreadImageView.hidden = isFirst;
}

#pragma mark - IBActions

- (IBAction)didClickCommentButton:(UIButton *)sender
{
    if (_comment) {
        [self commentStatus];
    } else if(_status){
        [self viewCommentOfStatus];
    }
}

- (IBAction)didClickUserNameButton:(UIButton *)sender
{
    NSString *userName = [sender titleForState:UIControlStateDisabled];
    [self sendUserNameClickedNotificationWithName:userName];
}

- (IBAction)didClickMoreActionButton:(UIButton *)sender
{
    if (_comment) {
        NSString *deleteTitle = [self.comment.author isEqualToUser:[UserAccountManager currentUser]] ? @"删除" : nil;
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self 
                                                        cancelButtonTitle:nil 
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"复制评论", deleteTitle, nil];
        actionSheet.destructiveButtonIndex = kActionSheetCommentDelete;
        actionSheet.delegate = self;
        [actionSheet showFromRect:sender.bounds inView:sender animated:YES];
    } else if (_status) {
        NSString *favourTitle = self.status.favorited.boolValue ? @"取消收藏" : @"收藏";
        NSString *deleteTitle = [self.status.author isEqualToUser:[UserAccountManager currentUser]] ? @"删除" : nil;
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self 
                                                        cancelButtonTitle:nil 
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"转发", favourTitle, @"复制微博", @"邮件分享", deleteTitle, nil];
        actionSheet.destructiveButtonIndex = kActionSheetStatusDeleteIndex;
        actionSheet.delegate = self;
        [actionSheet showFromRect:sender.bounds inView:sender animated:YES];
    }
    
    
}

- (void)commentStatus
{
    NSString *targetUserName = self.comment.author.screenName;
    NSString *targetStatusID = self.comment.targetStatus.statusID;
    NSString *targetReplyID = self.comment.commentID;
    CGRect frame = [self convertRect:_commentButton.frame toView:[UIApplication sharedApplication].rootViewController.view];
    
    PostViewController *vc = [PostViewController getCommentReplyViewControllerWithWeiboID:targetStatusID replyID:targetReplyID weiboOwnerName:targetUserName delegate:self];
    [vc showViewFromRect:frame];
}

- (void)viewCommentOfStatus
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldShowCommentList object:[NSDictionary dictionaryWithObjectsAndKeys:self.status, kNotificationObjectKeyStatus, [NSString stringWithFormat:@"%i", self.pageIndex], kNotificationObjectKeyIndex, nil]];
}

#pragma mark - TTTAttributedLabel Delegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)userName
{
    [self sendUserNameClickedNotificationWithName:userName];
}

- (void)sendUserNameClickedNotificationWithName:(NSString *)userName
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldShowUserByName object:[NSDictionary dictionaryWithObjectsAndKeys:userName, kNotificationObjectKeyUserName, [NSString stringWithFormat:@"%i", self.pageIndex], kNotificationObjectKeyIndex, nil]];
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

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (_comment) {
        if(buttonIndex == kActionSheetCommentCopyIndex) {
            UIPasteboard *pb = [UIPasteboard generalPasteboard];
            [pb setString:self.comment.text];
        } else if(buttonIndex == kActionSheetCommentDelete) {
            [self deleteComment];
        }
    } else {
        if(buttonIndex == kActionSheetStatusRepostIndex) {
            [self repostStatus];
        } else if(buttonIndex == kActionSheetStatusFavorIndex) {
            //TODO:
        } else if(buttonIndex == kActionSheetStatusShareIndex) {
            [self shareStatusByMail];
        } else if(buttonIndex == kActionSheetStatusCopyIndex){
            [self copyStatus];
        } else if(buttonIndex == kActionSheetStatusDeleteIndex){
            //TODO:
        }
    }
}

- (void)repostStatus
{
    NSString *targetUserName = self.status.author.screenName;
    NSString *targetStatusID = self.status.statusID;
    NSString *targetStatusContent = nil;
    if(self.status.repostStatus)
        targetStatusContent = self.status.text;
    CGRect frame = [self convertRect:self.moreActionButton.frame toView:[UIApplication sharedApplication].rootViewController.view];
    PostViewController *vc = [PostViewController getRepostViewControllerWithWeiboID:targetStatusID
                                                                     weiboOwnerName:targetUserName
                                                                            content:targetStatusContent
                                                                           delegate:self];
    [vc showViewFromRect:frame];
}

- (void)copyStatus
{
    NSString *statusText = [NSString stringWithFormat:@"%@:@%@:%@", self.status.text, self.status.repostStatus.author.screenName, self.status.repostStatus.text];

    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:statusText];
}

- (void)sendShowRepostListNotification
{
    Status *targetStatus = self.status.repostStatus;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldShowRepostList object:[NSDictionary dictionaryWithObjectsAndKeys:targetStatus, kNotificationObjectKeyStatus, [NSString stringWithFormat:@"%i", self.pageIndex], kNotificationObjectKeyIndex, nil]];
}

- (void)shareStatusByMail
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    picker.modalPresentationStyle = UIModalPresentationPageSheet;
    
    NSString *subject = [NSString stringWithFormat:@"分享一条来自新浪的微博，作者：%@", self.status.author.screenName];
    
    [picker setSubject:subject];
    NSString *emailBody = [NSString stringWithFormat:@"%@ %@", self.status.text, self.status.repostStatus.text];
    [picker setMessageBody:emailBody isHTML:NO];
    
    [[[UIApplication sharedApplication] rootViewController] presentModalViewController:picker animated:YES];
}

- (void)deleteComment
{
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldDeleteComment object:self.comment.commentID];
        } else {
            //TODO: Handle Error
        }
    }];
    
    [client deleteComment:self.comment.commentID];
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController*)controller
		  didFinishWithResult:(MFMailComposeResult)result 
						error:(NSError*)error
{
	NSString *message = nil;
	switch (result)
	{
		case MFMailComposeResultSaved:
			message = NSLocalizedString(@"保存成功", nil);
            [[[UIApplication sharedApplication] rootViewController] dismissModalViewControllerAnimated:YES];
			break;
		case MFMailComposeResultSent:
			message = NSLocalizedString(@"发送成功", nil);
            [[[UIApplication sharedApplication] rootViewController] dismissModalViewControllerAnimated:YES];
			break;
		case MFMailComposeResultFailed:
			message = NSLocalizedString(@"发送失败", nil);
			break;
		default:
            [[[UIApplication sharedApplication] rootViewController] dismissModalViewControllerAnimated:YES];
			return;
	}
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message 
														message:nil
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"确定", nil)
											  otherButtonTitles:nil];
	[alertView show];
}


@end
