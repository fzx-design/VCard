//
//  UnreadIndicatorView.m
//  VCard
//
//  Created by 海山 叶 on 12-6-29.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "UnreadIndicatorView.h"
#import "UIView+Resize.h"

#define kUnreadIndicatorViewHeight              40.0
#define kUnreadIndicatorViewOriginInitial       240.0
#define kUnreadIndicatorViewTerminalOriginX     -250.0

#define kUnreadIndicatorViewOriginInitialPoint  CGPointMake(5.0, 240.0)

@interface UnreadIndicatorView ()

@property (nonatomic, strong) UIImageView *backgroundImageView;

@end

@implementation UnreadIndicatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _currentIndicatorCount = 0;
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 60.0, 172.0, 180.0)];
        _backgroundImageView.image = [UIImage imageNamed:@"notification_shadow.png"];
        _backgroundImageView.alpha = 0.0;
        _backgroundImageView.userInteractionEnabled = NO;
        [self insertSubview:_backgroundImageView atIndex:1];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _currentIndicatorCount = 0;
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 60.0, 172.0, 180.0)];
        _backgroundImageView.image = [UIImage imageNamed:@"notification_shadow.png"];
        _backgroundImageView.alpha = 0.0;
        _backgroundImageView.userInteractionEnabled = NO;
        [self insertSubview:_backgroundImageView atIndex:1];
    }
    return self;
}

- (void)addNewIndicator:(UnreadIndicatorButton *)indicator
{
    if (_currentIndicatorCount == 0) {
        [self showBackgroundImageView];
    }
    _currentIndicatorCount++;
    [self sendSubviewToBack:_backgroundImageView];
    
    indicator.hidden = NO;
    [indicator resetOrigin:kUnreadIndicatorViewOriginInitialPoint];
    [self adjustHalfPixel];
    [indicator adjustHalfPixel];
    
    CGFloat targetHeight = 4 * kUnreadIndicatorViewHeight + 27.0;
    
    for (UIView *view in self.subviews) {
        CGFloat currentOriginY = view.frame.origin.y;
        if (currentOriginY != kUnreadIndicatorViewOriginInitial && ![view isKindOfClass:[UIImageView class]]) {
            [UIView animateWithDuration:0.5 animations:^{
                [view resetOriginY:currentOriginY - kUnreadIndicatorViewHeight];
            }];
        }
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        [indicator resetOriginY:targetHeight];
    } completion:^(BOOL finished) {
        [indicator showIndicatingAnimation];
    }];
}

- (void)removeIndicator:(UnreadIndicatorButton *)indicator
{
    _currentIndicatorCount--;
    if (_currentIndicatorCount == 0) {
        [self hideBackgroundImageView];
    }
    
    CGFloat removingHeight = indicator.frame.origin.y;
    for (UIView *view in self.subviews) {
        CGFloat currentOriginY = view.frame.origin.y;
        if (currentOriginY != kUnreadIndicatorViewOriginInitial && currentOriginY < removingHeight && ![view isKindOfClass:[UIImageView class]]) {
            [UIView animateWithDuration:0.5 animations:^{
                [view resetOriginY:currentOriginY + kUnreadIndicatorViewHeight];
            }];
        }
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        indicator.alpha = 0.0;
        [indicator resetOriginX:kUnreadIndicatorViewTerminalOriginX];
    } completion:^(BOOL finished) {
        indicator.alpha = 1.0;
        indicator.hidden = YES;
    }];
}

- (void)showBackgroundImageView
{
    BlockARCWeakSelf weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.backgroundImageView.alpha = 1.0;
    }];
}

- (void)hideBackgroundImageView
{
    BlockARCWeakSelf weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.backgroundImageView.alpha = 0.0;
    }];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL result = NO;
    for (UIView *view in self.subviews) {
        CGPoint targetPoint = [self convertPoint:point toView:view];
        if ([view pointInside:targetPoint withEvent:event] && ![view isKindOfClass:[UIImageView class]]) {
            result = YES;
            break;
        }
    }
    return result;
}

@end
