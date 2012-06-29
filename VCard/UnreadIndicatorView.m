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
#define kUnreadIndicatorViewOriginInitial       129.0
#define kUnreadIndicatorViewTerminalOriginX     -200.0

#define kUnreadIndicatorViewOriginInitialPoint  CGPointMake(5.0,129.0)

@implementation UnreadIndicatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _currentIndicatorCount = 0;
    }
    return self;
}

- (void)addNewIndicator:(UnreadIndicatorButton *)indicator
{
    _currentIndicatorCount++;
    indicator.hidden = NO;
    [indicator resetOrigin:kUnreadIndicatorViewOriginInitialPoint];
    CGFloat targetHeight = 2 * kUnreadIndicatorViewHeight;
    
    for (UIView *view in self.subviews) {
        CGFloat currentOriginY = view.frame.origin.y;
        if (currentOriginY != kUnreadIndicatorViewOriginInitial) {
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
    CGFloat removingHeight = indicator.frame.origin.y;
    for (UIView *view in self.subviews) {
        CGFloat currentOriginY = view.frame.origin.y;
        if (currentOriginY != kUnreadIndicatorViewOriginInitial && currentOriginY < removingHeight) {
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

@end
