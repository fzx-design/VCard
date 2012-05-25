//
//  RefreshIndicatorView.m
//  VCard
//
//  Created by 海山 叶 on 12-5-25.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "RefreshIndicatorView.h"
#import <QuartzCore/QuartzCore.h>

@implementation RefreshIndicatorView

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
        // Initialization code
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        [self setUpImageViews];
    }
    return self;
}

- (void)setUpImageViews
{
    _refreshHoleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kRLRefreshButtonHole]];
    _refreshHoleImageView.frame = CGRectMake(0.0, 0.0, 23.0, 23.0);
    [self addSubview:_refreshHoleImageView];
    
    _refreshCircleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kRLRefreshButtonCircle]];
    _refreshCircleImageView.frame = CGRectMake(2.0, 1.0, 19.0, 19.0);
    [self addSubview:_refreshCircleImageView];
}

- (void)startLoadingAnimation
{
    _refreshCircleImageView.alpha = 1.0;
	_refreshHoleImageView.alpha = 1.0;
	
	CABasicAnimation *rotationAnimation =[CABasicAnimation animationWithKeyPath:@"transform.rotation"];
	rotationAnimation.duration = 1.0;
	rotationAnimation.fromValue = [NSNumber numberWithFloat:0.0];
	rotationAnimation.toValue = [NSNumber numberWithFloat:2.0 * M_PI];
	rotationAnimation.repeatCount = 65535;
	[_refreshCircleImageView.layer addAnimation:rotationAnimation forKey:@"kAnimationLoad"];
}

- (void)stopLoadingAnimation
{
    _refreshCircleImageView.alpha = 1.0;
    [_refreshCircleImageView.layer removeAllAnimations];
}

@end
