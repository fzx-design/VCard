//
//  BaseNavigationView.m
//  VCard
//
//  Created by 海山 叶 on 12-4-18.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "BaseNavigationView.h"
#import "ResourceList.h"
#import "UIView+Resize.h"

#define kInfoBarImageViewFrame          CGRectMake(0, 0, 768, 33)
#define kInfoBarReturnButtonFrame       CGRectMake(0, 0, 90, 30)
#define kInfoBarTitleLabelFrame         CGRectMake(0, 0, 768, 30)
#define kInfoBarReturnButtonTextColor   [UIColor colorWithHue:70.0 / 255.0 saturation:70.0 / 255.0 brightness:70.0 / 255.0 alpha:1.0]
#define kInfoBarTitleLabelTextColor     [UIColor colorWithHue:45.0 / 255.0 saturation:45.0 / 255.0 brightness:45.0 / 255.0 alpha:1.0]

@implementation BaseNavigationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        _topBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 768, 44)];
        _topBar.image = [[UIImage imageNamed:kRLTopBarBG] resizableImageWithCapInsets:UIEdgeInsetsZero];
        [_topBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        
        _topBarShadow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44, 768, 15)];
        [_topBarShadow setImage:[UIImage imageNamed:kRLTopBarShadow]];
        [_topBarShadow setContentMode:UIViewContentModeScaleToFill];
        [_topBarShadow setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        
        [self insertSubview:_topBar atIndex:0];
        [self insertSubview:_topBarShadow atIndex:0];
        
        [self setUpInfoBar];
        
    }
    return self;
}

- (void)setUpInfoBar
{
    _infoBarView = [[UIImageView alloc] initWithFrame:kInfoBarImageViewFrame];
    _infoBarView.image = [[UIImage imageNamed:@"banner_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsZero];
    _infoBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    _returnButton = [[UIButton alloc] initWithFrame:kInfoBarReturnButtonFrame];
    [_returnButton setTitle:@"查看全部" forState:UIControlStateNormal];
    [_returnButton setTitle:@"查看全部" forState:UIControlStateHighlighted];
    [_returnButton setTitleColor:kInfoBarReturnButtonTextColor forState:UIControlStateNormal];
    [_returnButton setTitleColor:kInfoBarReturnButtonTextColor forState:UIControlStateHighlighted];
    [_returnButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_returnButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_returnButton setBackgroundImage:[UIImage imageNamed:@"button_flat.png"] forState:UIControlStateNormal];
    [_returnButton setBackgroundImage:[UIImage imageNamed:@"button_flat_hover.png"] forState:UIControlStateHighlighted];
    _returnButton.autoresizingMask = UIViewAutoresizingNone;
    _returnButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
    _returnButton.titleLabel.shadowColor = [UIColor whiteColor];
    _returnButton.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    
    [_returnButton addTarget:self
                      action:@selector(didClickReturnButton)
            forControlEvents:UIControlEventTouchUpInside];
    
    _titleLabel = [[UILabel alloc] initWithFrame:kInfoBarTitleLabelFrame];
    _titleLabel.text = @"";
    _titleLabel.textAlignment = UITextAlignmentCenter;
    _titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    _titleLabel.textColor = kInfoBarTitleLabelTextColor;
    _titleLabel.shadowColor = [UIColor whiteColor];
    _titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _titleLabel.backgroundColor = [UIColor clearColor];
    
    _infoBarView.hidden = YES;
    _returnButton.hidden = YES;
    _titleLabel.hidden = YES;
    
    [self insertSubview:_infoBarView belowSubview:_topBar];
    [self insertSubview:_titleLabel belowSubview:_topBar];
    [self insertSubview:_returnButton belowSubview:_topBar];
}

- (void)showInfoBarWithTitleName:(NSString *)name
{
    _infoBarView.hidden = NO;
    _returnButton.hidden = NO;
    _titleLabel.hidden = NO;
    
    [UIView animateWithDuration:0.15 animations:^{
        _titleLabel.alpha = 0.0;
    } completion:^(BOOL finished) {
        _titleLabel.text = name;
        [UIView animateWithDuration:0.15 animations:^{
            _titleLabel.alpha = 1.0;
        }];
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        [_infoBarView resetOriginY:43.0];
        [_returnButton resetOriginY:43.0];
        [_titleLabel resetOriginY:43.0];
        [_topBarShadow resetOriginY:73.0];
    }];
}

- (void)hideInfoBar
{
    [UIView animateWithDuration:0.3 animations:^{
        [_infoBarView resetOriginY:0.0];
        [_returnButton resetOriginY:0.0];
        [_titleLabel resetOriginY:0.0];
        [_topBarShadow resetOriginY:43.0];
    } completion:^(BOOL finished) {
        _infoBarView.hidden = YES;
        _returnButton.hidden = YES;
        _titleLabel.hidden = YES;
    }];
}

- (void)didClickReturnButton
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldReturnToNormalTimeline object:nil];
}

@end
