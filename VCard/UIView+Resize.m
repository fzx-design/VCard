//
//  UIView+Resize.m
//  VCard
//
//  Created by 海山 叶 on 12-5-23.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "UIView+Resize.h"

@implementation UIView (Resize)

- (void)resetOriginX:(CGFloat)originX
{
    CGRect frame = self.frame;
    frame.origin.x = originX;
    self.frame = frame;
}

- (void)resetOriginY:(CGFloat)originY
{
    CGRect frame = self.frame;
    frame.origin.y = originY;
    self.frame = frame;
}

- (void)resetHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (void)resetWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (void)resetOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (void)resetSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (void)resetFrameWithOrigin:(CGPoint)origin size:(CGSize)size
{
    CGRect frame = self.frame;
    frame.origin = origin;
    frame.size = size;
    self.frame = frame;
}

@end
