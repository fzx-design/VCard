//
//  BaseCardBackgroundView.m
//  VCard
//
//  Created by 海山 叶 on 12-4-14.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "BaseCardBackgroundView.h"
#import "ResourceList.h"
#import "ResourceProvider.h"

#define HeightTopView 20
#define HeightBottomView 38

#define CenterTileRect CGRectMake(0.0, 0.0, 362, 54)

@implementation BaseCardBackgroundView

@synthesize cardTopView = _cardTopView;
@synthesize cardBottomView = _cardBottomView;
@synthesize cardCenterView = _cardCenterView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupBackgroundImageView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupBackgroundImageView];
    }
    return self;
}


//- (void)resetHeight:(CGFloat)height
//{
//    CGRect frame = self.frame;
//    frame.size.height = height;
//    self.frame = frame;
//    
//    [self setNeedsDisplay];
//}

- (void)setupBackgroundImageView
{
    
    CGRect frame = self.frame;
    
    CGRect topViewFrame = CGRectMake(0.0 , 0.0, frame.size.width, HeightTopView);
    CGRect bottomViewFrame = CGRectMake(0.0, 0.0 + frame.size.height - HeightBottomView, frame.size.width, HeightBottomView);
    CGRect centerViewFrame = CGRectMake(0.0, 0.0  + HeightTopView, frame.size.width, frame.size.height - HeightTopView - HeightBottomView);
//    CGRect backgroundImageViewFrame = CGRectMake(0.0 , 0.0, frame.size.width, frame.size.height);
    
    _cardTopView = [[UIImageView alloc] initWithFrame:topViewFrame];
    _cardBottomView = [[UIImageView alloc] initWithFrame:bottomViewFrame];
    _cardCenterView = [[UIImageView alloc] initWithFrame:centerViewFrame];
//    _backgroundImageView = [[UIView alloc] initWithFrame:backgroundImageViewFrame];
    
    [_cardTopView setImage:[UIImage imageNamed:kRLCardTop]];
    [_cardBottomView setImage:[UIImage imageNamed:kRLCardBottom]];
    
    [_cardCenterView setImage:[[UIImage imageNamed:kRLCardBGUnit] resizableImageWithCapInsets:UIEdgeInsetsZero]];
    
    [_cardTopView setContentMode:UIViewContentModeTop];
    [_cardBottomView setContentMode:UIViewContentModeBottom];
    
    _cardTopView.autoresizingMask = UIViewAutoresizingNone;
    _cardCenterView.autoresizingMask = UIViewAutoresizingNone;
    _cardBottomView.autoresizingMask = UIViewAutoresizingNone;
    
    [self addSubview:_cardTopView];
    [self addSubview:_cardCenterView];
    [self addSubview:_cardBottomView];    

//    _cardCenterView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kRLCardBGUnit]];
    
//    [_backgroundImageView addSubview:_cardTopView];
//    [_backgroundImageView addSubview:_cardCenterView];
//    [_backgroundImageView addSubview:_cardBottomView];
    
//    [self addSubview:_backgroundImageView];
    
}

- (void)resetHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
    
    CGRect topViewFrame = CGRectMake(0.0 , 0.0, frame.size.width, HeightTopView);
    CGRect bottomViewFrame = CGRectMake(0.0, 0.0 + frame.size.height - HeightBottomView, frame.size.width, HeightBottomView);
    CGRect centerViewFrame = CGRectMake(0.0, 0.0  + HeightTopView, frame.size.width, frame.size.height - HeightTopView - HeightBottomView);
//    CGRect backgroundImageViewFrame = CGRectMake(0.0 , 0.0, frame.size.width, frame.size.height);
    
    [_cardTopView setFrame:topViewFrame];
    [_cardBottomView setFrame:bottomViewFrame];
    [_cardCenterView setFrame:centerViewFrame];
//    [_backgroundImageView setFrame:backgroundImageViewFrame];
}

- (void)layoutSubviews
{
//    [self sendSubviewToBack:_backgroundImageView];
    
    [self sendSubviewToBack:_cardTopView];
    [self sendSubviewToBack:_cardCenterView];
    [self sendSubviewToBack:_cardBottomView];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//    // Drawing code
//    CGContextRef currentContext = UIGraphicsGetCurrentContext();
//    
//    CGContextTranslateCTM(currentContext, 0, rect.size.height);
//    CGContextScaleCTM(currentContext, 1.0, -1.0);
//    
//    CGRect topRect = CGRectMake(rect.origin.x, rect.size.height - HeightTopView, rect.size.width,
//                                HeightTopView);
//
//    CGContextDrawImage(currentContext, topRect, [ResourceProvider topImageRef]);
//    
//    
//    CGRect bottomRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, HeightBottomView);
//    CGContextDrawImage(currentContext, bottomRect, [ResourceProvider bottomImageRef]);
//    
//    CGFloat centerHeight = rect.size.height - HeightTopView - HeightBottomView;
//    CGRect centerFrame = CGRectMake(rect.origin.x, HeightBottomView, rect.size.width, centerHeight);
//    
//    CGContextClipToRect(currentContext, centerFrame);
//    CGRect centerTileRect = CenterTileRect;
//    CGContextDrawTiledImage(currentContext, centerTileRect, [ResourceProvider centerTileImageRef]);
//    
//}

@end
