//
//  UIView+Swing.m
//  VCard
//
//  Created by 海山 叶 on 12-7-15.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "UIView+Swing.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (Swing)

#pragma mark - Animation

- (void)swingOncetoAngle:(CGFloat)toAngle withAnchorPoint:(CGPoint)anchorPoint position:(CGPoint)position
{
    self.layer.anchorPoint = anchorPoint;
    self.layer.position = position;
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.toValue = @(toAngle);
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    rotationAnimation.fillMode = kCAFillModeForwards;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.duration = 0.1;
    
    [self.layer removeAllAnimations];
    [self.layer addAnimation:rotationAnimation forKey:@"swingAnimation"];
}

- (void)swingHaltfromAngle:(CGFloat)fromAngle withAnchorPoint:(CGPoint)anchorPoint position:(CGPoint)position
{
    self.layer.anchorPoint = anchorPoint;
    self.layer.position = position;
    
    CAAnimationGroup* animationGroup = [CAAnimationGroup animation];
    NSMutableArray* animationArray = [NSMutableArray arrayWithCapacity:5];
    
    for (int i = 0; i < 5; i++) {
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        rotationAnimation.toValue = [NSNumber numberWithFloat:((4-i)/5.0)*((4-i)/5.0)*fromAngle*(-1+2*(i%2))];
        rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        rotationAnimation.fillMode = kCAFillModeForwards;
        rotationAnimation.removedOnCompletion = NO;
        rotationAnimation.duration = 0.4;
        rotationAnimation.beginTime = i * 0.4;
        
        if (i == 0) {
            rotationAnimation.fromValue = @(fromAngle);
        }
        
        [animationArray addObject:rotationAnimation];
    }
    [animationGroup setAnimations:animationArray];
    [animationGroup setDuration:2.0];
    
    [self.layer removeAllAnimations];
    [self.layer addAnimation:animationGroup forKey:@"swingAnimation"];
}


@end
