//
//  UIView+Resize.h
//  VCard
//
//  Created by 海山 叶 on 12-5-23.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Resize)

- (void)resetOriginX:(CGFloat)originX;

- (void)resetOriginY:(CGFloat)originY;

- (void)resetWidth:(CGFloat)width;

- (void)resetHeight:(CGFloat)height;

- (void)resetOrigin:(CGPoint)origin;

- (void)resetSize:(CGSize)size;

- (void)resetFrameWithOrigin:(CGPoint)origin size:(CGSize)size;

@end
