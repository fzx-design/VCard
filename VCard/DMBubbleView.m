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

#define kReceivedOrigin         CGPointMake(20.0, 16.0)
#define kSentOrigin             CGPointMake(12.0, 18.0)
#define kReceivedRightOffset    10.0
#define kSentRightOffset        22.0
#define kReceicedBottomOffset   14.0
#define kSentBottomOffset       12.0
#define kTimeStampLabelColor    [UIColor colorWithRed:161.0 / 255.0 green:161.0 / 255.0 blue:161.0 / 255.0 alpha:1.0]
#define kTimeStampLabelHeight   20.0
#define kTimeStampLabelGap      5.0

@interface DMBubbleView () {
    CGFloat _originXOffset;
    CGFloat _originYOffset;
    CGFloat _rightOffset;
    CGFloat _bottomOffset;
    
    CGRect _backgroundImageViewFrame;
    CGRect _textLabelFrame;
    CGSize _textSize;
}

@end

@implementation DMBubbleView

+ (CGSize)sizeForText:(NSString *)text fontSize:(CGFloat)fontSize leading:(CGFloat)leadingSize
{
    CGFloat height = 50.0f;
    CGFloat width = 0.0f;
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:kMaxBubbleSize lineBreakMode:UILineBreakModeWordWrap];
    CGFloat singleLineHeight = ceilf([@"测试单行高度" sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:kMaxBubbleSize lineBreakMode:UILineBreakModeWordWrap].height);
    int lineCount = size.height / singleLineHeight - 1;
    int leading = leadingSize - 2;
    
    height += ceilf(size.height + lineCount * leading) + kTimeStampLabelHeight + kTimeStampLabelGap ;
    width += ceilf(size.width);
    
    return CGSizeMake(width, height);
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        CGRect frame = self.frame;
        _textLabel = [[TTTAttributedLabel alloc] initWithFrame:frame];
        _textLabel.backgroundColor = [UIColor clearColor];
        
        _timeStampLabel = [[UILabel alloc] initWithFrame:frame];
        _timeStampLabel.backgroundColor = [UIColor clearColor];
        _timeStampLabel.textColor = kTimeStampLabelColor;
        _timeStampLabel.font = [UIFont boldSystemFontOfSize:12.0];
        _timeStampLabel.textAlignment = UITextAlignmentRight;
        [_timeStampLabel resetHeight:20.0];
        
        _backgroundImageView = [[UIImageView alloc] initWithFrame:frame];
        
        [self addSubview:_backgroundImageView];
        [self addSubview:_textLabel];
        [self addSubview:_timeStampLabel];
    }
    return self;
}

- (void)setTextSize:(NSString *)text
{
    CGFloat height = 0.0f;
    CGFloat width = 0.0f;
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:[NSUserDefaults currentFontSize]] constrainedToSize:kMaxBubbleSize lineBreakMode:UILineBreakModeWordWrap];
    CGFloat singleLineHeight = ceilf([@"测试单行高度" sizeWithFont:[UIFont systemFontOfSize:[NSUserDefaults currentFontSize]] constrainedToSize:kMaxBubbleSize lineBreakMode:UILineBreakModeWordWrap].height);
    int lineCount = size.height / singleLineHeight;
    lineCount -= lineCount / 3;
    int leading = [NSUserDefaults currentLeading];
    
    height += ceilf(size.height + lineCount * leading);
    width += ceilf(size.width) + 5.0;
    if (width < 120.0) {
        width = 120.0;
    }
    
    _textSize = CGSizeMake(width, height);
}

- (void)resetWithText:(NSString *)text dateString:(NSString *)dateString type:(DMBubbleViewType)type
{
    [self setTextSize:text];
    _timeStampLabel.text = dateString;
    [_textLabel resetWidth:_textSize.width];
    [_textLabel resetHeight:_textSize.height];
    [TTTAttributedLabelConfiguer setMessageTextLabel:_textLabel withText:text];
    
    [self resetWithType:type];
}

- (void)resetWithType:(DMBubbleViewType)type
{
    CGFloat fixedWidth = kMaxBubbleSize.width + _originXOffset + _rightOffset;
    CGFloat targetWidth = _textSize.width < fixedWidth ? _textSize.width + _originXOffset + _rightOffset : kMaxBubbleSize.width;
    CGFloat targetOriginX = 0.0;
    NSString *imageName = @"";
    
    if (type == DMBubbleViewTypeSent) {
        _originXOffset = kSentOrigin.x;
        _originYOffset = kSentOrigin.y;
        _rightOffset = kSentRightOffset;
        _bottomOffset = kSentBottomOffset;
        targetOriginX = fixedWidth - targetWidth;
        imageName = @"cell_bg_msg_blue.png";
    } else {
        _originXOffset = kReceivedOrigin.x;
        _originYOffset = kReceivedOrigin.y;
        _rightOffset = kReceivedRightOffset;
        _bottomOffset = kReceicedBottomOffset;
        targetOriginX = 0.0;
        imageName = @"cell_bg_msg.png";
    }
    
    [_textLabel resetOrigin:CGPointMake(targetOriginX + _originXOffset + 3.0, _originYOffset)];
    _textLabelFrame = _textLabel.frame;
    
    _backgroundImageViewFrame.origin.x = targetOriginX;
    _backgroundImageViewFrame.origin.y = 0.0;
    _backgroundImageViewFrame.size.height = _textLabelFrame.size.height + _originYOffset + _bottomOffset + kTimeStampLabelHeight + kTimeStampLabelGap;
    _backgroundImageViewFrame.size.width = _textLabelFrame.size.width + _originXOffset + _rightOffset;
    _backgroundImageView.frame = _backgroundImageViewFrame;
    _backgroundImageView.image = [[UIImage imageNamed:imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(_originYOffset, _originXOffset, _bottomOffset, _rightOffset)];
    
    [_timeStampLabel resetOriginX:_textLabelFrame.origin.x];
    [_timeStampLabel resetWidth:_textLabelFrame.size.width - 10.0];
    [_timeStampLabel resetOriginY:_textLabelFrame.origin.y + _textLabelFrame.size.height + kTimeStampLabelGap];
}


@end
