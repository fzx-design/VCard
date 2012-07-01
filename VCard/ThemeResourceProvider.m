//
//  ThemeResourceProvider.m
//  VCard
//
//  Created by Gabriel Yeah on 12-6-26.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "ThemeResourceProvider.h"

@implementation ThemeResourceProvider

+ (void)configBackButtonDark:(UIButton *)button
{
    UIEdgeInsets insets = UIEdgeInsetsMake(0.0, 16.0, 0.0, 8.0);
    [button setBackgroundImage:[[UIImage imageNamed:kRLBackButtonDarkBG] resizableImageWithCapInsets:insets]
                      forState:UIControlStateNormal];
    [button setBackgroundImage:[[UIImage imageNamed:kRLBackButtonDarkHoverBG] resizableImageWithCapInsets:insets]
                      forState:UIControlStateHighlighted];
}

+ (void)configButtonBrown:(UIButton *)button
{
    UIEdgeInsets insets = UIEdgeInsetsMake(0.0, 8.0, 0.0, 8.0);
    [button setBackgroundImage:[[UIImage imageNamed:kRLButtonBrownBG] resizableImageWithCapInsets:insets]
                      forState:UIControlStateNormal];
    [button setBackgroundImage:[[UIImage imageNamed:kRLButtonBrownHoverBG] resizableImageWithCapInsets:insets]
                      forState:UIControlStateHighlighted];
}

+ (void)configButtonDark:(UIButton *)button
{
    UIEdgeInsets insets = UIEdgeInsetsMake(0.0, 8.0, 0.0, 8.0);
    [button setBackgroundImage:[[UIImage imageNamed:kRLButtonDarkBG] resizableImageWithCapInsets:insets]
                      forState:UIControlStateNormal];
    [button setBackgroundImage:[[UIImage imageNamed:kRLButtonDarkHoverBG] resizableImageWithCapInsets:insets]
                      forState:UIControlStateHighlighted];
}

+ (void)configButtonPaperLight:(UIButton *)button
{
    UIEdgeInsets insets = UIEdgeInsetsMake(0.0, 8.0, 0.0, 8.0);
    [button setBackgroundImage:[[UIImage imageNamed:kRLButtonPaperLightBG] resizableImageWithCapInsets:insets]
                      forState:UIControlStateNormal];
    [button setBackgroundImage:[[UIImage imageNamed:kRLButtonPaperLightHoverBG] resizableImageWithCapInsets:insets]
                      forState:UIControlStateHighlighted];
}

+ (void)configButtonPaperDark:(UIButton *)button
{
    UIEdgeInsets insets = UIEdgeInsetsMake(0.0, 8.0, 0.0, 8.0);
    [button setBackgroundImage:[[UIImage imageNamed:kRLButtonPaperDarkBG] resizableImageWithCapInsets:insets]
                      forState:UIControlStateNormal];
    [button setBackgroundImage:[[UIImage imageNamed:kRLButtonPaperDarkHoverBG] resizableImageWithCapInsets:insets]
                      forState:UIControlStateHighlighted];
}

+ (void)configButtonUnreadIndicator:(UIButton *)button
{
    UIEdgeInsets insets = UIEdgeInsetsMake(0.0, 11.0, 0.0, 11.0);
    [button setBackgroundImage:[[UIImage imageNamed:kRLButtonUnreadIndicatorBG] resizableImageWithCapInsets:insets]
                      forState:UIControlStateNormal];
    [button setBackgroundImage:[[UIImage imageNamed:kRLButtonUnreadIndicatorBG] resizableImageWithCapInsets:insets]
                      forState:UIControlStateHighlighted];
    [button setBackgroundImage:[[UIImage imageNamed:kRLButtonUnreadIndicatorBG] resizableImageWithCapInsets:insets]
                      forState:UIControlStateDisabled];
}


@end
