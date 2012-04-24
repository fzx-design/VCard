//
//  BaseNavigationView.m
//  VCard
//
//  Created by 海山 叶 on 12-4-18.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "BaseNavigationView.h"
#import "ResourceList.h"

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
        
        UIImageView *topBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 768, 43)];
        topBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kRLTopBarBG]];
        [topBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        
        UIImageView *topBarShadow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 43, 768, 15)];
        [topBarShadow setImage:[UIImage imageNamed:kRLTopBarShadow]];
        [topBarShadow setContentMode:UIViewContentModeScaleToFill];
        [topBarShadow setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        
        [self insertSubview:topBar atIndex:0];
        [self insertSubview:topBarShadow atIndex:0];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end