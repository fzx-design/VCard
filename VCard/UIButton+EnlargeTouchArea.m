//
//  UIButton+EnlargeTouchArea.m
//  VCard
//
//  Created by 海山 叶 on 12-6-26.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "UIButton+EnlargeTouchArea.h"

@implementation UIButton (EnlargeTouchArea)

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect bounds = self.bounds;
    CGFloat heightDelta = 44.0 - bounds.size.height;
    bounds = CGRectInset(bounds, 0, -0.5 * heightDelta);
    return CGRectContainsPoint(bounds, point);
}

@end
