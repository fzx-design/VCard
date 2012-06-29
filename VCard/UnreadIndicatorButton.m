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
        [self addSubview:_highlightImageView];
    }
    return self;
}

- (void)showIndicatingAnimation
{
    CAAnimationGroup* animationGroup = [CAAnimationGroup animation];
    NSMutableArray* animationArray = [NSMutableArray arrayWithCapacity:6];
    
    for (int i = 0; i < 6; i++) {
        CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnim.fromValue = [NSNumber numberWithFloat:i % 2];
        opacityAnim.toValue = [NSNumber numberWithFloat:i % 2 + 1.0];
        opacityAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        opacityAnim.fillMode = kCAFillModeForwards;
        opacityAnim.removedOnCompletion = YES;
        opacityAnim.duration = 0.4;
        
        [animationArray addObject:opacityAnim];
        
//        CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
//        opacityAnim.fromValue = [NSNumber numberWithFloat:1.0];
//        opacityAnim.toValue = [NSNumber numberWithFloat:0.1];
//        opacityAnim.removedOnCompletion = YES;
    }
    [animationGroup setAnimations:animationArray];
    [animationGroup setDuration:2.0];

    [_highlightImageView.layer removeAllAnimations];
    [_highlightImageView.layer addAnimation:animationGroup forKey:@"alphaAnimation"];
}

- (void)showIndicatorUpdatedAnimation
{
    
}

@end
