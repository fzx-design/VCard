//
//  UIButton+EnlargeTouchArea.m
//  VCard
//
//  Created by Gabriel Yeah on 12-7-24.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "UIButton+EnlargeTouchArea.h"

@implementation UIButton (EnlargeTouchArea)

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect bounds = self.bounds;
    CGFloat widthDelta = 44.0 - bounds.size.width;
    CGFloat heighDelta = 44.0 - bounds.size.height;
    widthDelta = widthDelta < 0.0 ? 0.0 : widthDelta;
    heighDelta = heighDelta < 0.0 ? 0.0 : heighDelta;
    bounds = CGRectInset(bounds, -0.5 * widthDelta, -0.5 * heighDelta);
    return CGRectContainsPoint(bounds, point);
}

@end
