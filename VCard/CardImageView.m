//
//  CardImageView.m
//  VCard
//
//  Created by 海山 叶 on 12-4-14.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "CardImageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation CardImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _shadowView = [[CardImageViewShadowView alloc] initWithFrame:frame];
        [self insertSubview:_shadowView atIndex:0];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _shadowView = [[CardImageViewShadowView alloc] initWithFrame:self.frame];
        [self insertSubview:_shadowView atIndex:0];
        
        CGFloat rotatingDegree = (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * 4) - 2;
        
        self.transform = CGAffineTransformMakeRotation(rotatingDegree * M_PI / 180); //rotation in radians
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
