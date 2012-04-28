//
//  CardImageViewShadowView.m
//  VCard
//
//  Created by 海山 叶 on 12-4-16.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "CardImageViewShadowView.h"
#import "ResourceList.h"

#define HeightShadowTopView 18
#define HeightShadowBottomView 15

#define TopOriginYOffset -16.5
#define TopOriginXOffset -0.5
#define CenterOriginYOffset 9
#define BottomOriginYOffset -22.5

#define Width 379

@implementation CardImageViewShadowView

@synthesize topView = _topView;
@synthesize bottomView = _bottomView;
@synthesize centerView = _centerView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupBackgroundImageView];
    }
    return self;
}

- (void)setupBackgroundImageView
{
    
    CGRect frame = self.frame;
    
    CGRect topViewFrame = CGRectMake(TopOriginXOffset , TopOriginYOffset, Width, HeightShadowTopView);
    CGRect bottomViewFrame = CGRectMake(TopOriginXOffset, BottomOriginYOffset + frame.size.height, Width, HeightShadowBottomView);
    CGRect centerViewFrame = CGRectMake(TopOriginXOffset, TopOriginYOffset + HeightShadowTopView, Width, frame.size.height + CenterOriginYOffset - HeightShadowTopView - HeightShadowBottomView);
    
    _topView = [[UIImageView alloc] initWithFrame:topViewFrame];
    _bottomView = [[UIImageView alloc] initWithFrame:bottomViewFrame];
    _centerView = [[UIImageView alloc] initWithFrame:centerViewFrame];
    
    [_topView setImage:[UIImage imageNamed:kRLCardImageShadowTop]];
    [_bottomView setImage:[UIImage imageNamed:kRLCardImageShadowBottom]];
    [_topView setContentMode:UIViewContentModeTop];
    [_bottomView setContentMode:UIViewContentModeBottom];
    
    _topView.autoresizingMask = UIViewAutoresizingNone;
    _centerView.autoresizingMask = UIViewAutoresizingNone;
    _bottomView.autoresizingMask = UIViewAutoresizingNone;
    
    _centerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kRLCardImageShadowCenter]];
    
    [self addSubview:_topView];
    [self addSubview:_centerView];
    [self addSubview:_bottomView];
}

- (void)resetHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
    
    CGRect topViewFrame = CGRectMake(TopOriginXOffset , TopOriginYOffset, Width, HeightShadowTopView);
    CGRect bottomViewFrame = CGRectMake(TopOriginXOffset, BottomOriginYOffset + frame.size.height, Width, HeightShadowBottomView);
    CGRect centerViewFrame = CGRectMake(TopOriginXOffset, TopOriginYOffset + HeightShadowTopView, Width, frame.size.height + CenterOriginYOffset - HeightShadowTopView - HeightShadowBottomView);
    
    [_topView setFrame:topViewFrame];
    [_bottomView setFrame:bottomViewFrame];
    [_centerView setFrame:centerViewFrame];
}

- (void)layoutSubviews
{
    [self sendSubviewToBack:_topView];
    [self sendSubviewToBack:_centerView];
    [self sendSubviewToBack:_bottomView];
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
