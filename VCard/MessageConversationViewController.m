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
#define kFooterViewOriginalHeight 54.0

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
    [ThemeResourceProvider configButtonPaperDark:_viewProfileButton];
    
    _textViewBackgroundImageView.image = [[UIImage imageNamed:@"msg_textfield_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(13, 0, 12, 0)];
    _footerBackgroundImageView.image = [[UIImage imageNamed:@"msg_sendfield_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 0, 25, 0)];
    
    _textView.delegate = self;
    _prevTextViewContentHeight = _textView.contentSize.height;
    [_textView resetOrigin:CGPointMake(1.0, 0.0)];
    [_textViewBackgroundImageView addSubview:_textView];
    
    _topCoverImageView.image = [[UIImage imageNamed:kRLCastViewBGUnit] resizableImageWithCapInsets:UIEdgeInsetsZero];

    _sendButton.enabled = NO;
    
    [self.conversationTableViewController initialLoadMessageData];
    
    [NSNotificationCenter registerTimerFiredNotificationWithSelector:@selector(timerFired) target:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self layoutFooterViewWithKeyboardHeight:_keyboardHeight footerViewHeight:_footerView.frame.size.height];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_conversationTableViewController viewWillDisappear:animated];
}

- (void)stackDidScroll
{
    [self.textView resignFirstResponder];
}

- (void)pagePopedFromStack
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
}

#pragma mark - Notification
- (void)resetLayoutBeforeRotating:(NSNotification *)notification
{
    [self layoutFooterViewWithKeyboardHeight:_keyboardHeight footerViewHeight:_footerView.frame.size.height];
}

- (void)resetLayoutAfterRotating:(NSNotification *)notification
{
    [self layoutFooterViewWithKeyboardHeight:_keyboardHeight footerViewHeight:_footerView.frame.size.height];
}

#pragma mark Text View

- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *info = [notification userInfo];
    CGRect keyboardBounds = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = [UIApplication isCurrentOrientationLandscape] ? keyboardBounds.size.width : keyboardBounds.size.height;
    _keyboardHeight = keyboardHeight;
    
    if (!self.isActive) {
        return;
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        [self layoutFooterViewWithKeyboardHeight:_keyboardHeight footerViewHeight:_footerView.frame.size.height];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    _keyboardHeight = 0;
    [UIView animateWithDuration:0.25f animations:^{
        [self layoutFooterViewWithKeyboardHeight:0 footerViewHeight:_footerView.frame.size.height];
    }];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.delegate stackViewPage:self shouldBecomeActivePageAnimated:YES];
    [self layoutFooterViewWithKeyboardHeight:_keyboardHeight footerViewHeight:_footerView.frame.size.height];
}

- (void)layoutFooterViewWithKeyboardHeight:(CGFloat)keyboardHeight footerViewHeight:(CGFloat)footerViewHeight
{
    CGFloat footerViewOriginY = self.view.frame.size.height - _keyboardHeight - footerViewHeight;
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
    [_conversationTableViewController.view resetHeightByOffset:-offset];
    
}

#pragma mark - IBActions
- (IBAction)didClickEmoticonButton:(UIButton *)sender
{
    
}

- (IBAction)didClickSendButton:(UIButton *)sender
{
    NSString *text = _textView.text;
    if (text && ![text isEqualToString:@""]) {
        [self sendMessage:text];
    }
}

- (IBAction)didClickViewProfileButton:(UIButton *)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldShowUserByName object:@{kNotificationObjectKeyUserName: _conversation.targetUser.screenName, kNotificationObjectKeyIndex: [NSString stringWithFormat:@"%i", self.pageIndex]}];
}

#pragma mark - Message Methods
- (void)sendMessage:(NSString *)message
{
    WBClient *client = [WBClient client];
    
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            self.textView.text = @"";
            [self.conversationTableViewController receivedNewMessage:client.responseJSONObject];
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
        _conversationTableViewController.firstLoad = YES;
    }
    return _conversationTableViewController;
}

@end
