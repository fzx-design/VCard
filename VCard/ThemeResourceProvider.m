//
//  ThemeResourceProvider.m
//  VCard
//
//  Created by Gabriel Yeah on 12-6-26.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "ThemeResourceProvider.h"

@implementation ThemeResourceProvider

+ (UIImage *)backButtonDarkBGForState:(UIControlState)state
{
    NSString *imageName = @"";
    switch (state) {
        case UIControlStateHighlighted:
            imageName = kRLBackButtonDarkHoverBG;
            break;
        default:
            imageName = kRLBackButtonDarkBG;
            break;
    }
    
    return [[UIImage imageNamed:imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 16.0, 0.0, 8.0)];
}

+ (UIImage *)buttonBrownBGForState:(UIControlState)state
{
    NSString *imageName = @"";
    switch (state) {
        case UIControlStateHighlighted:
            imageName = kRLButtonBrownHoverBG;
            break;
        default:
            imageName = kRLButtonBrownBG;
            break;
    }
    
    return [[UIImage imageNamed:imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 8.0, 0.0, 8.0)];
}

+ (UIImage *)buttonDarkBGForState:(UIControlState)state
{
    NSString *imageName = @"";
    switch (state) {
        case UIControlStateHighlighted:
            imageName = kRLButtonDarkHoverBG;
            break;
        default:
            imageName = kRLButtonDarkBG;
            break;
    }
    
    return [[UIImage imageNamed:imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 8.0, 0.0, 8.0)];
}

+ (UIImage *)buttonPaperLightBGForState:(UIControlState)state
{
    NSString *imageName = @"";
    switch (state) {
        case UIControlStateHighlighted:
            imageName = kRLButtonPaperLightHoverBG;
            break;
        default:
            imageName = kRLButtonPaperLightBG;
            break;
    }
    
    return [[UIImage imageNamed:imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 8.0, 0.0, 8.0)];
}

+ (UIImage *)buttonPaperDarkBGForState:(UIControlState)state
{
    NSString *imageName = @"";
    switch (state) {
        case UIControlStateHighlighted:
            imageName = kRLButtonPaperDarkHoverBG;
            break;
        default:
            imageName = kRLButtonPaperDarkBG;
            break;
    }
    
    return [[UIImage imageNamed:imageName] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 8.0, 0.0, 8.0)];
}

@end
