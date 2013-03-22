//
//  RefreshIndicatorView.m
//  VCard
//
//  Created by 海山 叶 on 12-5-25.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "RefreshIndicatorView.h"
#import <QuartzCore/QuartzCore.h>

@interface RefreshIndicatorView() {
    RefreshIndicatorViewType _viewType;
}

@end

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
        _refreshHoleImageView = [[UIImageView alloc] init];
        _refreshCircleImageView = [[UIImageView alloc] init];
        [self setUpImageViews];
    }
    return self;
}

- (void)setType:(RefreshIndicatorViewType)type {
    _viewType = type;
    [self setUpImageViews];
}

- (void)setUpImageViews
{
    if (_viewType == RefreshIndicatorViewTypeSmallBlue) {
        _refreshHoleImageView.image = [UIImage imageNamed:kRLRefreshButtonHole];
        _refreshHoleImageView.frame = CGRectMake(0.0, 0.0, 23.0, 23.0);
        
        _refreshCircleImageView.image = [UIImage imageNamed:kRLRefreshButtonCircle];
        _refreshCircleImageView.frame = CGRectMake(2.0, 1.0, 19.0, 19.0);
        
    } else if (_viewType == RefreshIndicatorViewTypeLargeWhite) {
        _refreshHoleImageView.image = [UIImage imageNamed:@"icon_error_edge"];
        _refreshHoleImageView.frame = CGRectMake(0.0, 0.0, 90.0, 90.0);
        
        _refreshCircleImageView.image = [UIImage imageNamed:@"icon_circle_large"];
        _refreshCircleImageView.frame = CGRectMake(9.0, 8.0, 72.0, 72.0);
    }
    [self addSubview:_refreshHoleImageView];
    [self addSubview:_refreshCircleImageView];
}

- (void)startLoadingAnimation
{
    _refreshCircleImageView.alpha = 1.0;
	_refreshHoleImageView.alpha = 1.0;
	
	CABasicAnimation *rotationAnimation =[CABasicAnimation animationWithKeyPath:@"transform.rotation"];
	rotationAnimation.duration = 1.0;
	rotationAnimation.fromValue = @0.0f;
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
