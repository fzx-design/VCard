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

@interface MessageConversationViewController () {
    CGFloat _keyboardHeight;
    CGFloat _textViewHeight;
}

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
    [self.backgroundView addSubview:self.conversationTableViewController.view];
    [self.topShadowImageView resetOriginY:[self frameForTableView].origin.y];
    [self.topShadowImageView resetOriginX:0.0];
    [self.view insertSubview:self.topShadowImageView belowSubview:_footerView];
    _titleLabel.text = _conversation.targetUser.screenName;
    [ThemeResourceProvider configButtonPaperLight:_clearHistoryButton];
    [ThemeResourceProvider configButtonPaperDark:_viewProfileButton];
    
    _textViewBackgroundImageView.image = [[UIImage imageNamed:@"msg_textfield_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(13, 0, 12, 0)];
    _footerBackgroundImageView.image = [[UIImage imageNamed:@"msg_sendfield_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 0, 25, 0)];
    
    _textView.delegate = self;
    _textViewHeight = _textView.contentSize.height;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
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
    if ([(NSString *)notification.object isEqualToString:kOrientationPortrait]) {
        CGFloat height = 961.0 - 50.0 - _footerView.frame.size.height;
        [self.conversationTableViewController.view resetHeight:height];
    }
}

- (void)resetLayoutAfterRotating:(NSNotification *)notification
{
    if ([UIApplication isCurrentOrientationLandscape]) {
        CGFloat height = 705.0 - 50.0 - _footerView.frame.size.height;
        [self.conversationTableViewController.view resetHeight:height];
    }
}

#pragma mark Text View

- (void)keyboardWillShow:(NSNotification *)notification {
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

- (void)layoutFooterView
{
    CGFloat footerViewOriginY = self.view.frame.size.height - _keyboardHeight - _footerView.frame.size.height;
    CGFloat tableViewHeight = footerViewOriginY - self.conversationTableViewController.view.frame.origin.y;
    [_footerView resetOriginY:footerViewOriginY];
    [self.conversationTableViewController.view resetHeight:tableViewHeight];
    [self.conversationTableViewController scrollToBottom];
}

- (void)textViewDidChange:(UITextView *)textView
{
    
//    NSLog(@"%@", NSStringFromCGPoint(textView.contentOffset));
    _textView.contentOffset = CGPointZero;
    if (_textViewHeight != textView.contentSize.height) {
        _textViewHeight = textView.contentSize.height;
        CGFloat offset = _textView.contentSize.height - _textView.frame.size.height;
        [_textView resetHeight:_textView.contentSize.height];
        [_footerView resetHeightByOffset:offset];
        [_footerView resetOriginYByOffset:-offset];
        
        _textViewBackgroundImageView.frame = _textView.frame;
        [_sendButton resetOriginY:_sendButton.frame.origin.y + offset / 2];
        [_emoticonButton resetOriginY:_emoticonButton.frame.origin.y + offset / 2];
        [self.conversationTableViewController.view resetHeightByOffset:-offset];
        [self.conversationTableViewController scrollToBottom];
    }
}

#pragma mark - IBActions
- (IBAction)didClickEmoticonButton:(UIButton *)sender
{
    
}

- (IBAction)didClickSendButton:(UIButton *)sender
{
    
}

- (IBAction)didClickViewProfileButton:(UIButton *)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldShowUserByName object:[NSDictionary dictionaryWithObjectsAndKeys:_conversation.targetUser.screenName, kNotificationObjectKeyUserName, [NSString stringWithFormat:@"%i", self.pageIndex], kNotificationObjectKeyIndex, nil]];
}

- (IBAction)didClickClearHistoryButton:(UIButton *)sender {
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
