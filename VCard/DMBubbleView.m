//
//  DMBubbleView.m
//  VCard
//
//  Created by 海山 叶 on 12-7-21.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "DMBubbleView.h"
#import "UIView+Resize.h"
#import "CardViewController.h"
#import "UIView+Resize.h"
#import "TTTAttributedLabelConfiguer.h"
#import "NSUserDefaults+Addition.h"
#import "UIView+Addition.h"
#import "NSString+Addition.h"
#import "InnerBrowserViewController.h"

#define kReceivedOrigin         CGPointMake(20.0, 16.0)
#define kSentOrigin             CGPointMake(12.0, 18.0)
#define kReceivedRightOffset    10.0
#define kSentRightOffset        22.0
#define kReceicedBottomOffset   14.0
#define kSentBottomOffset       12.0
#define kTimeStampLabelColor    [UIColor colorWithRed:161.0 / 255.0 green:161.0 / 255.0 blue:161.0 / 255.0 alpha:1.0]
#define kTimeStampLabelHeight   20.0
#define kTimeStampLabelGap      5.0

#define kFontSize               14.0
#define kLeadingSize            6.0

@interface DMBubbleView () {
    CGFloat _originXOffset;
    CGFloat _originYOffset;
    CGFloat _rightOffset;
    CGFloat _bottomOffset;
    
    CGRect _backgroundImageViewFrame;
    CGRect _textLabelFrame;
    CGSize _textSize;
    
    BOOL   _readyForAction;
}

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

@end

@implementation DMBubbleView

+ (CGSize)sizeForText:(NSString *)text
{
    CGFloat height = 50.0f;
    CGFloat width = 0.0f;
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:kFontSize] constrainedToSize:kMaxTextSize lineBreakMode:UILineBreakModeWordWrap];
    CGFloat singleLineHeight = ceilf([@"测试单行高度" sizeWithFont:[UIFont systemFontOfSize:kFontSize] constrainedToSize:kMaxTextSize lineBreakMode:UILineBreakModeWordWrap].height);
    int lineCount = size.height / singleLineHeight;
    lineCount -= lineCount / 3;
    int leading = kLeadingSize;
    
    height += ceilf(size.height + lineCount * leading) + kTimeStampLabelHeight + kTimeStampLabelGap ;
    width += ceilf(size.width);
    
    return CGSizeMake(width, height);
}

- (void)setTextSize:(NSString *)text
{
    CGFloat height = 0.0f;
    CGFloat width = 0.0f;
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:kFontSize] constrainedToSize:kMaxTextSize lineBreakMode:UILineBreakModeWordWrap];
    CGFloat singleLineHeight = ceilf([@"测试单行高度" sizeWithFont:[UIFont systemFontOfSize:kFontSize] constrainedToSize:kMaxTextSize lineBreakMode:UILineBreakModeWordWrap].height);
    int lineCount = size.height / singleLineHeight;
    lineCount -= lineCount / 3;
    int leading = kLeadingSize;
    
    height += ceilf(size.height + lineCount * leading);
    width += ceilf(size.width) + 5.0;
    if (width < 120.0) {
        width = 120.0;
    }
    
    _textSize = CGSizeMake(width, height);
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        CGRect frame = self.frame;
        _textLabel = [[TTTAttributedLabel alloc] initWithFrame:frame];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.displaySmallEmoticon = YES;
        _textLabel.delegate = self;
        
        _timeStampLabel = [[UILabel alloc] initWithFrame:frame];
        _timeStampLabel.backgroundColor = [UIColor clearColor];
        _timeStampLabel.textColor = kTimeStampLabelColor;
        _timeStampLabel.font = [UIFont boldSystemFontOfSize:12.0];
        _timeStampLabel.textAlignment = UITextAlignmentRight;
        [_timeStampLabel resetHeight:20.0];
        
        _backgroundImageView = [[UIImageView alloc] initWithFrame:frame];
        _highlightCoverImageView = [[UIImageView alloc] initWithFrame:frame];
        _highlightCoverImageView.hidden = YES;
        
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        _longPressGesture.minimumPressDuration = 0.5;
        [self addGestureRecognizer:_longPressGesture];
        
        [self addSubview:_backgroundImageView];
        [self addSubview:_highlightCoverImageView];
        [self addSubview:_textLabel];
        [self addSubview:_timeStampLabel];
    }
    return self;
}

- (void)resetWithText:(NSString *)text dateString:(NSString *)dateString type:(DMBubbleViewType)type
{
    self.text = text;
    [self setTextSize:text];
    _timeStampLabel.text = dateString;
    [_textLabel resetWidth:_textSize.width];
    [_textLabel resetHeight:_textSize.height];
    [TTTAttributedLabelConfiguer setMessageTextLabel:_textLabel withText:text leading:kLeadingSize fontSize:kFontSize isReceived:type == DMBubbleViewTypeReceived];
    [self resetWithType:type];
}

- (void)resetWithType:(DMBubbleViewType)type
{
    CGFloat fixedWidth = kMaxBubbleSize.width + _originXOffset + _rightOffset;
    CGFloat targetWidth = _textSize.width < fixedWidth ? _textSize.width + _originXOffset + _rightOffset : kMaxBubbleSize.width;
    CGFloat targetOriginX = 0.0;
    NSString *imageName = @"";
    NSString *hightlightImageName = @"";
    
    if (type == DMBubbleViewTypeSent) {
        _originXOffset = kSentOrigin.x;
        _originYOffset = kSentOrigin.y;
        _rightOffset = kSentRightOffset;
        _bottomOffset = kSentBottomOffset;
        targetOriginX = fixedWidth - targetWidth;
        imageName = @"cell_bg_msg_blue.png";
        hightlightImageName = @"cell_bg_msg_blue_hover.png";
        
    } else {
        _originXOffset = kReceivedOrigin.x;
        _originYOffset = kReceivedOrigin.y;
        _rightOffset = kReceivedRightOffset;
        _bottomOffset = kReceicedBottomOffset;
        targetOriginX = 0.0;
        imageName = @"cell_bg_msg.png";
        hightlightImageName = @"cell_bg_msg_hover.png";
    }
    
    [_textLabel resetOrigin:CGPointMake(targetOriginX + _originXOffset + 4.0, _originYOffset - 2.0)];
    _textLabelFrame = _textLabel.frame;
    
    _backgroundImageViewFrame.origin.x = targetOriginX;
    _backgroundImageViewFrame.origin.y = 0.0;
    _backgroundImageViewFrame.size.height = _textLabelFrame.size.height + _originYOffset + _bottomOffset + kTimeStampLabelHeight + kTimeStampLabelGap;
    _backgroundImageViewFrame.size.width = _textLabelFrame.size.width + _originXOffset + _rightOffset + 6.0;
    _backgroundImageView.frame = _backgroundImageViewFrame;
    _backgroundImageView.image = [[UIImage imageNamed:imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(_originYOffset, _originXOffset, _bottomOffset, _rightOffset)];
    
    _highlightCoverImageView.image = [[UIImage imageNamed:hightlightImageName] resizableImageWithCapInsets:UIEdgeInsetsMake(_originYOffset, _originXOffset, _bottomOffset, _rightOffset)];
    _highlightCoverImageView.frame = _backgroundImageView.frame;
    
    [_timeStampLabel resetOriginX:_textLabelFrame.origin.x];
    [_timeStampLabel resetWidth:_textLabelFrame.size.width - 5.0];
    [_timeStampLabel resetOriginY:_textLabelFrame.origin.y + _textLabelFrame.size.height + kTimeStampLabelGap];
    
    [self resetHeight:_backgroundImageView.frame.size.height];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self showHighlight];
        [self showActionSheet];
    } else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled || gesture.state ==UIGestureRecognizerStateFailed) {
        _readyForAction = NO;
    }
}

- (void)showHighlight
{
    _readyForAction = YES;
    _highlightCoverImageView.hidden = NO;
    _highlightCoverImageView.alpha = 0.0;
    [_highlightCoverImageView fadeInWithCompletion:^{
//        if (!_readyForAction) {
//            [self hideHighlight];
//        }
    }];
}

- (void)hideHighlight
{
    [_highlightCoverImageView fadeOutWithCompletion:^{
        _highlightCoverImageView.hidden = YES;
        _readyForAction = YES;
    }];
}

- (void)showActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"复制", @"删除", nil];
    actionSheet.delegate = self;
    actionSheet.destructiveButtonIndex = 1;
    [actionSheet showFromRect:self.backgroundImageView.frame inView:self animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self hideHighlight];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        [pb setString:[self.text replaceRegExWithEmoticons]];
    } else if (buttonIndex == 1) {
        if ([self.delegate respondsToSelector:@selector(shouldDeleteBubble)]) {
            [self.delegate shouldDeleteBubble];
        }
    }
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
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldShowUserByName object:@{kNotificationObjectKeyUserName: userName, kNotificationObjectKeyIndex: [NSString stringWithFormat:@"%i", self.pageIndex]}];
    }
}

- (void)sendShowTopicNotification:(NSString *)searchKey
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldShowTopic object:@{kNotificationObjectKeySearchKey: searchKey, kNotificationObjectKeyIndex: [NSString stringWithFormat:@"%i", self.pageIndex]}];
}

@end
