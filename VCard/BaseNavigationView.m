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
        _topBar.clipsToBounds = YES;
        [_topBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        
        _topBarShadow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44, 768, 15)];
        [_topBarShadow setImage:[UIImage imageNamed:kRLTopBarShadow]];
        [_topBarShadow setContentMode:UIViewContentModeScaleToFill];
        [_topBarShadow setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        
        [self insertSubview:_topBar atIndex:0];
        [self insertSubview:_topBarShadow atIndex:0];
        
        
    }
    return self;
}



@end
