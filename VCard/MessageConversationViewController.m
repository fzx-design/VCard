//
//  MessageConversationViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-7-21.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "MessageConversationViewController.h"
#import "Conversation.h"
#import "UIApplication+Addition.h"
#import "WBClient.h"
#import "NSNotificationCenter+Addition.h"

#define kTextViewMaxHeight 160.0

@interface MessageConversationViewController () {
    CGFloat _keyboardHeight;
    CGFloat _prevTextViewContentHeight;
}

@property (nonatomic, unsafe_unretained) BOOL isEditing;

@end

@implementation MessageConversationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.topShadowImageView resetOrigin:[self frameForTableView].origin];
    [self.backgroundView insertSubview:self.topShadowImageView belowSubview:_footerView];
    [self.backgroundView insertSubview:self.conversationTableViewController.view belowSubview:self.topShadowImageView];
    _titleLabel.text = _conversation.targetUser.screenName;
    [ThemeResourceProvider configButtonPaperLight:_clearHistoryButton];
    [ThemeResourceProvider configButtonPaperDark:_viewProfileButton];
    
    _textViewBackgroundImageView.image = [[UIImage imageNamed:@"msg_textfield_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(13, 0, 12, 0)];
    _footerBackgroundImageView.image = [[UIImage imageNamed:@"msg_sendfield_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 0, 25, 0)];
    
    _textView.delegate = self;
    _prevTextViewContentHeight = _textView.contentSize.height;
    [_textView resetOrigin:CGPointMake(1.0, -2.0)];
    [_textViewBackgroundImageView addSubview:_textView];
    
    _topCoverImageView.image = [[UIImage imageNamed:kRLCastViewBGUnit] resizableImageWithCapInsets:UIEdgeInsetsZero];

    _sendButton.enabled = NO;
    
    [NSNotificationCenter registerTimerFiredNotificationWithSelector:@selector(timerFired) target:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)clearPage
{
    [_conversationTableViewController.view removeFromSuperview];
    _conversationTableViewController = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self layoutFooterView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_conversationTableViewController viewWillDisappear:NO];
}

- (void)stackDidScroll
{
    [self.textView resignFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self 
               selector:@selector(resetLayoutAfterRotating:) 
                   name:kNotificationNameOrientationChanged
                 object:nil];
    [center addObserver:self 
               selector:@selector(resetLayoutBeforeRotating:) 
                   name:kNotificationNameOrientationWillChange
                 object:nil];
    [center addObserver:self
               selector:@selector(keyboardWillShow:)
                   name:UIKeyboardWillShowNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(keyboardWillHide:)
                   name:UIKeyboardWillHideNotification
                 object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initialLoad
{
    [self.conversationTableViewController initialLoadMessageData];
}

#pragma mark - Notification
- (void)resetLayoutBeforeRotating:(NSNotification *)notification
{
    [self layoutFooterView];
}

- (void)resetLayoutAfterRotating:(NSNotification *)notification
{
    [self layoutFooterView];
}

#pragma mark Text View

- (void)keyboardWillShow:(NSNotification *)notification {
    
    if (!self.isActive) {
        return;
    }
    
    NSDictionary *info = [notification userInfo];
    CGRect keyboardBounds = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = [UIApplication isCurrentOrientationLandscape] ? keyboardBounds.size.width : keyboardBounds.size.height;
    _keyboardHeight = keyboardHeight;
    
    [UIView animateWithDuration:0.25f animations:^{
        [self layoutFooterView];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    _keyboardHeight = 0;
    [UIView animateWithDuration:0.25f animations:^{
        [self layoutFooterView];
    }];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.delegate stackViewPage:self shouldBecomeActivePageAnimated:YES];
}

- (void)layoutFooterView
{
    CGFloat footerViewOriginY = self.view.frame.size.height - _keyboardHeight - _footerView.frame.size.height;
    CGFloat tableViewHeight = footerViewOriginY - self.conversationTableViewController.view.frame.origin.y + 1;
    [_footerView resetOriginY:footerViewOriginY];
    [self.conversationTableViewController.view resetHeight:tableViewHeight];
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (_prevTextViewContentHeight != textView.contentSize.height) {
        _prevTextViewContentHeight = textView.contentSize.height;
        
        CGFloat targetHeight = _prevTextViewContentHeight;
        
        if (targetHeight > kTextViewMaxHeight) {
            _textView.scrollEnabled = YES;
            _textView.clipsToBounds = YES;
            targetHeight = kTextViewMaxHeight;
        } else {
            _textView.scrollEnabled = NO;
            _textView.clipsToBounds = NO;
        }
        
        [self resizeTextView:targetHeight];
    }
    _sendButton.enabled = ![textView.text isEqualToString:@""];
}

- (void)resizeTextView:(CGFloat)targetHeight
{
    CGFloat offset = targetHeight - _textViewBackgroundImageView.frame.size.height - 2;
    [_footerView resetHeightByOffset:offset];
    [_footerBackgroundImageView resetHeightByOffset:offset];
    [_footerView resetOriginYByOffset:-offset];

    [_textViewBackgroundImageView resetHeight:targetHeight - 2];
    [_textView resetHeight:targetHeight - 6];
    
    [_sendButton resetOriginY:_sendButton.frame.origin.y + offset];
    [_emoticonButton resetOriginY:_emoticonButton.frame.origin.y + offset];
    [self.conversationTableViewController.view resetHeightByOffset:-offset];
    [self.conversationTableViewController scrollToBottom:NO];
    
}

#pragma mark - IBActions
- (IBAction)didClickEmoticonButton:(UIButton *)sender
{
    
}

- (IBAction)didClickSendButton:(UIButton *)sender
{
    [self sendMessage:_textView.text];
}

- (IBAction)didClickViewProfileButton:(UIButton *)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldShowUserByName object:@{kNotificationObjectKeyUserName: _conversation.targetUser.screenName, kNotificationObjectKeyIndex: [NSString stringWithFormat:@"%i", self.pageIndex]}];
}

- (IBAction)didClickClearHistoryButton:(UIButton *)sender {
    
}

#pragma mark - Message Methods
- (void)sendMessage:(NSString *)message
{
    WBClient *client = [WBClient client];
    
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            [self.conversationTableViewController receivedNewMessage:client.responseJSONObject];
            self.textView.text = @"";
        }
    }];
    
    [client sendDirectMessage:message toUser:_conversation.targetUser.screenName];
}

- (void)timerFired
{
    [_conversationTableViewController getUnreadMessage];
}

#pragma mark - Properties
- (CGRect)frameForTableView
{
    CGFloat originY = 50;
    CGFloat height = self.view.frame.size.height - originY - _footerView.frame.size.height;
    return CGRectMake(24.0, originY, 382.0, height);
}

- (DMConversationTableViewController *)conversationTableViewController
{
    if (!_conversationTableViewController) {
        _conversationTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DMConversationTableViewController"];
        _conversationTableViewController.view.frame = [self frameForTableView];
        _conversationTableViewController.tableView.frame = [self frameForTableView];
        _conversationTableViewController.conversation = _conversation;
    }
    return _conversationTableViewController;
}

@end
