//
//  UnreadIndicatorButton.m
//  VCard
//
//  Created by 海山 叶 on 12-6-29.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UnreadIndicatorButton.h"

@implementation UnreadIndicatorButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _highlightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-4.0, -8.0, 160.0, 50.0)];
        _highlightImageView.image = [UIImage imageNamed:@"activity_highlight.png"];
        _highlightImageView.alpha = 0.0;
        [self addSubview:_highlightImageView];
    }
    return self;
}

- (void)showIndicatingAnimation
{

    CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOutAnimation.fromValue = [NSNumber numberWithFloat:0];
    fadeOutAnimation.toValue = [NSNumber numberWithFloat:1];
    fadeOutAnimation.autoreverses = YES;
    fadeOutAnimation.duration = 0.5;
    fadeOutAnimation.removedOnCompletion = YES;
    fadeOutAnimation.repeatCount = 2;
        
    [_highlightImageView.layer removeAllAnimations];
    [_highlightImageView.layer addAnimation:fadeOutAnimation forKey:@"opacityAnimation"];
}

- (void)showIndicatorUpdatedAnimation
{
    CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOutAnimation.fromValue = [NSNumber numberWithFloat:0];
    fadeOutAnimation.toValue = [NSNumber numberWithFloat:1];
    fadeOutAnimation.autoreverses = YES;
    fadeOutAnimation.duration = 0.5;
    fadeOutAnimation.removedOnCompletion = YES;
    fadeOutAnimation.repeatCount = 1;
    
    [_highlightImageView.layer removeAllAnimations];
    [_highlightImageView.layer addAnimation:fadeOutAnimation forKey:@"animateLayer"];
}

@end
