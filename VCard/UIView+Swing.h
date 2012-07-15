//
//  UIView+Swing.h
//  VCard
//
//  Created by 海山 叶 on 12-7-15.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Swing)

- (void)swingOncetoAngle:(CGFloat)toAngle withAnchorPoint:(CGPoint)anchorPoint position:(CGPoint)position;

- (void)swingHaltfromAngle:(CGFloat)fromAngle withAnchorPoint:(CGPoint)anchorPoint position:(CGPoint)position;

@end
