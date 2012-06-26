//
//  ThemeResourceProvider.h
//  VCard
//
//  Created by Gabriel Yeah on 12-6-26.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThemeResourceProvider : NSObject

+ (UIImage *)backButtonDarkBGForState:(UIControlState)state;
+ (UIImage *)buttonBrownBGForState:(UIControlState)state;
+ (UIImage *)buttonDarkBGForState:(UIControlState)state;
+ (UIImage *)buttonPaperLightBGForState:(UIControlState)state;
+ (UIImage *)buttonPaperDarkBGForState:(UIControlState)state;

@end
