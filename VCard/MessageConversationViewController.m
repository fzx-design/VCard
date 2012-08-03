//
//  MessageConversationViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-7-21.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "MessageConversationViewController.h"
#import "Conversation.h"
#import "WBClient.h"
#import "EmoticonsViewController.h"
#import "PostAtHintView.h"
#import "PostTopicHintView.h"
#import "UIView+Addition.h"
#import "NSNotificationCenter+Addition.h"
#import "UIApplication+Addition.h"

#define kTextViewMaxHeight 160.0
#define kFooterViewOriginalHeight 54.0

#define OTHER_HINT_VIEW_HEIGHT      44
#define EMOTICONS_HINT_VIEW_HEIGHT  157
#define HINT_VIEW_OFFSET_Y          25

typedef enum {
    HintViewTypeEmoticons,
    HintViewTypeOther,
} HintViewType;

@interface MessageConversationViewController () {
    CGFloat _keyboardHeight;
    CGFloat _prevTextViewContentHeight;
}

@property (nonatomic, unsafe_unretained) BOOL isEditing;
@property (nonatomic, strong) EmoticonsViewController *emoticonsViewController;
@property (nonatomic, strong) PostHintView *currentHintView;

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
    
    _prevTextViewContentHeight = _textView.contentSize.height;
    [_textView resetOrigin:CGPointMake(1.0, 0.0)];
    [_textViewBackgroundImageView addSubview:_textView];
    UIEdgeInsets inset = _textView.contentInset;
    inset.top = -2.0;
    _textView.contentInset = inset;
    
    _topCoverImageView.image = [[UIImage imageNamed:kRLCastViewBGUnit] resizableImageWithCapInsets:UIEdgeInsetsZero];

    _sendButton.enabled = NO;
    
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

- (void)refresh
{
    [self.conversationTableViewController getUnreadMessage];
}

- (void)stackScrollingStartFromLeft:(BOOL)toLeft
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
    
    [self dismissHintView];
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    UIView *currentHintView = self.currentHintView;
    if([text isEqualToString:@"@"] && !currentHintView) {
        [self presentAtHintView];
    } else if([text isEqualToString:@"#"] && !currentHintView) {
        [self presentTopicHintView];
    }
    [self.textView shouldChangeTextInRange:range replacementText:text currentHintView:currentHintView];
    return YES;
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    [self.textView textViewDidChangeSelectionWithCurrentHintView:self.currentHintView];
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
            UIEdgeInsets inset = _textView.contentInset;
            inset.top = 0.0;
            _textView.contentInset = inset;
            targetHeight = kTextViewMaxHeight;
        } else {
            _textView.scrollEnabled = NO;
            _textView.clipsToBounds = NO;
            UIEdgeInsets inset = _textView.contentInset;
            inset.top = -2.0;
            _textView.contentInset = inset;
        }
        
        [self resizeTextView:targetHeight];
    }
    _sendButton.enabled = ![textView.text isEqualToString:@""];
    
    [self.textView textViewDidChangeWithCurrentHintView:self.currentHintView];
    [self updateCurrentHintView];
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
    [_emoticonsButton resetOriginY:_emoticonsButton.frame.origin.y + offset];
    [_conversationTableViewController.view resetHeightByOffset:-offset];
    
}

#pragma mark - IBActions

- (IBAction)didClickEmoticonButton:(UIButton *)sender
{
    BOOL select = !sender.isSelected;
    if(select) {
        [self.textView becomeFirstResponder];
        [self presentEmoticonsView];
    } else {
        [self dismissHintView];
    }
    sender.selected = select;
}

- (IBAction)didClickSendButton:(UIButton *)sender
{
    NSString *text = _textView.text;
    if (text && ![text isEqualToString:@""]) {
        [self sendMessage:text];
        [self dismissHintView];
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
    [_conversationTableViewController getUnreadMessageThroughTimer];
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
        _conversationTableViewController.pageIndex = self.pageIndex;
    }
    return _conversationTableViewController;
}

- (EmoticonsViewController *)emoticonsViewController {
    if(!_emoticonsViewController) {
        _emoticonsViewController = [[EmoticonsViewController alloc] init];
        _emoticonsViewController.delegate = self.textView;
    }
    return _emoticonsViewController;
}

#pragma mark - PostHintTextView delegate

- (void)postHintTextViewCallDismissHintView {
    [self dismissHintView];
}

- (void)dismissHintView {
    UIView *currentHintView = self.currentHintView;
    self.currentHintView = nil;
    [currentHintView fadeOutWithCompletion:^{
        [currentHintView removeFromSuperview];
    }];
    
    self.textView.currentHintStringRange = NSMakeRange(0, 0);
    self.textView.needFillPoundSign = NO;
    
    self.emoticonsButton.selected = NO;
    //self.postRootView.observingViewTag = PostRootViewSubviewTagNone;
}

#pragma mark - Emoticons and Hint View

- (CGPoint)hintViewOriginWithType:(HintViewType)type {
    CGPoint cursorPos = [self textViewCursorPos];
    if(type == HintViewTypeEmoticons) {
        cursorPos.y -= EMOTICONS_HINT_VIEW_HEIGHT + HINT_VIEW_OFFSET_Y;
    } else if(type == HintViewTypeOther) {
        CGFloat hintViewHeight = OTHER_HINT_VIEW_HEIGHT;
        if(self.currentHintView);
            hintViewHeight = self.currentHintView.frame.size.height;
        cursorPos.y -= hintViewHeight + HINT_VIEW_OFFSET_Y;
    }
    return cursorPos;
}

- (CGPoint)textViewCursorPos {
    CGPoint cursorPos = CGPointZero;
    if(self.textView.selectedTextRange.empty && self.textView.selectedTextRange) {
        cursorPos = [self.textView caretRectForPosition:self.textView.selectedTextRange.start].origin;
        cursorPos = [self.backgroundView convertPoint:cursorPos fromView:self.textView];
    }
    return cursorPos;
}

- (void)presentAtHintView {
    [self dismissHintView];
    CGPoint cursorPos = [self hintViewOriginWithType:HintViewTypeOther];
    if(CGPointEqualToPoint(cursorPos, CGPointZero))
        return;
    PostAtHintView *atView = [[PostAtHintView alloc] initWithCursorPos:cursorPos];
    atView.strechUpwards = YES;
    self.currentHintView = atView;
    atView.delegate = self.textView;
    [self checkCurrentHintViewFrame];
    [self.backgroundView addSubview:atView];
}

- (void)presentTopicHintView {
    [self dismissHintView];
    CGPoint cursorPos = [self hintViewOriginWithType:HintViewTypeOther];
    if(CGPointEqualToPoint(cursorPos, CGPointZero))
        return;
    PostTopicHintView *topicView = [[PostTopicHintView alloc] initWithCursorPos:cursorPos];
    topicView.strechUpwards = YES;
    self.currentHintView = topicView;
    topicView.delegate = self.textView;
    [self checkCurrentHintViewFrame];
    [self.backgroundView addSubview:topicView];
    [topicView updateHint:@""];
}

- (void)presentEmoticonsView {
    [self dismissHintView];
    _emoticonsViewController = nil;
    //self.postRootView.observingViewTag = PostRootViewSubviewTagEmoticons;
    EmoticonsViewController *vc = self.emoticonsViewController;
    vc.view.alpha = 1;
    [vc.view resetOrigin:[self hintViewOriginWithType:HintViewTypeEmoticons]];
    //vc.view.tag = PostRootViewSubviewTagEmoticons;
    [self.backgroundView addSubview:vc.view];
    self.currentHintView = (PostHintView *)vc.view;
    [self checkCurrentHintViewFrame];
    self.emoticonsButton.selected = YES;
    self.textView.currentHintStringRange = NSMakeRange(self.textView.selectedRange.location, 0);
}

- (void)updateCurrentHintView {
    [self updateCurrentHintViewFrame];
    [self updateCurrentHintViewContent];
}

- (void)updateCurrentHintViewFrame {
    if(!self.currentHintView)
        return;
    
    CGPoint cursorPos;
    if([self.currentHintView isKindOfClass:[PostHintView class]])
        cursorPos = [self hintViewOriginWithType:HintViewTypeOther];
    else
        cursorPos = [self hintViewOriginWithType:HintViewTypeEmoticons];
    
    if(!CGPointEqualToPoint(cursorPos, CGPointZero)) {
        [self.currentHintView resetOrigin:cursorPos];
        [self checkCurrentHintViewFrame];
    }
}

- (void)updateCurrentHintViewContent {
    if(!self.currentHintView)
        return;
    if([self.currentHintView isMemberOfClass:[PostAtHintView class]]) {
        if(self.textView.isAtHintStringValid)
            [self.currentHintView updateHint:self.textView.currentHintString];
        else {
            [self dismissHintView];
        }
    } else if([self.currentHintView isMemberOfClass:[PostTopicHintView class]]) {
        if(self.textView.isTopicHintStringValid)
            [self.currentHintView updateHint:self.textView.currentHintString];
        else {
            [self dismissHintView];
        }
    }
}

- (void)checkCurrentHintViewFrame {
    CGPoint pos = self.currentHintView.frame.origin;
    CGSize size = self.currentHintView.frame.size;
    CGPoint sendButtonOrigin = self.sendButton.frame.origin;
    sendButtonOrigin = [self.backgroundView convertPoint:sendButtonOrigin fromView:self.footerView];
    CGFloat maxHintViewBorderX = sendButtonOrigin.x + self.sendButton.frame.size.width;
    
    pos.x = pos.x + size.width > maxHintViewBorderX ? maxHintViewBorderX - size.width : pos.x;
    
    self.currentHintView.frame = CGRectMake(pos.x, pos.y, size.width, size.height);
}

@end
