//
//  BaseNavigationBar.m
//  VCard
//
//  Created by 海山 叶 on 12-4-14.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "BaseNavigationBar.h"
#import "ResourceList.h"

#define FrameTopBar CGRectMake(0, 0, 768, 43)
#define FrameTopBarShadow CGRectMake(0, 43, 768, 15)
#define FrameBorder CGRectMake(0, 43, 768, 1)

@implementation BaseNavigationBar

@synthesize backgroundImageView = _backgroundImageView;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {

        CGRect frame = self.frame;
        frame.size.height = 43;
        self.frame = frame;
        
        self.autoresizesSubviews = YES;

    }
    return self;
}

- (UIImageView *)backgroundImageView
{
    if (_backgroundImageView == nil)
    {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:[self bounds]];
        [_backgroundImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        
        UIImageView *topBar = [[UIImageView alloc] initWithFrame:FrameTopBar];
        topBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kRLTopBarBG]];
        [topBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        
        UIImageView *topBarShadow = [[UIImageView alloc] initWithFrame:FrameTopBarShadow];
        [topBarShadow setImage:[UIImage imageNamed:kRLTopBarShadow]];
        [topBarShadow setContentMode:UIViewContentModeScaleToFill];
        [topBarShadow setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        
        UIView *navBorder = [[UIView alloc] initWithFrame:FrameBorder]; 
        [navBorder setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [navBorder setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:kRLCastViewBGUnit]]];
        [navBorder setOpaque:YES];
        
        [_backgroundImageView addSubview:navBorder];
        [_backgroundImageView addSubview:topBar];
        [_backgroundImageView addSubview:topBarShadow];
        
        [self insertSubview:_backgroundImageView atIndex:0];
    }
    
    return _backgroundImageView;
}

- (void)layoutSubviews
{
    if (self.backgroundImageView != nil) {
        [self sendSubviewToBack:_backgroundImageView];
    }
}

- (void)drawRect:(CGRect)rect
{
    //Intended to be left blank
}

@end
