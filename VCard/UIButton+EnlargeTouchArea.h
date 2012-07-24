//
//  UIButton+EnlargeTouchArea.h
//  VCard
//
//  Created by Gabriel Yeah on 12-7-24.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (EnlargeTouchArea)

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event;

@end
