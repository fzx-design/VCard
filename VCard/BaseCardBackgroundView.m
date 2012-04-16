//
//  BaseCardBackgroundView.m
//  VCard
//
//  Created by 海山 叶 on 12-4-14.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "BaseCardBackgroundView.h"
#import "ResourceList.h"

#define HeightTopView 20
#define HeightBottomView 38

@implementation BaseCardBackgroundView

@synthesize cardTopView = _cardTopView;
@synthesize cardBottomView = _cardBottomView;
@synthesize cardCenterView = _cardCenterView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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

- (void)setupBackgroundImageView
{
    
    CGRect frame = self.frame;
    
    CGRect topViewFrame = CGRectMake(0.0 , 0.0, frame.size.width, HeightTopView);
    CGRect bottomViewFrame = CGRectMake(0.0, 0.0 + frame.size.height - HeightBottomView, frame.size.width, HeightBottomView);
    CGRect centerViewFrame = CGRectMake(0.0, 0.0  + HeightTopView, frame.size.width, frame.size.height - HeightTopView - HeightBottomView);
    CGRect backgroundImageViewFrame = CGRectMake(0.0 , 0.0, frame.size.width, frame.size.height);
    
    _cardTopView = [[UIImageView alloc] initWithFrame:topViewFrame];
    _cardBottomView = [[UIImageView alloc] initWithFrame:bottomViewFrame];
    _cardCenterView = [[UIImageView alloc] initWithFrame:centerViewFrame];
    _backgroundImageView = [[UIView alloc] initWithFrame:backgroundImageViewFrame];
    
    [_cardTopView setImage:[UIImage imageNamed:kRLCardTop]];
    [_cardBottomView setImage:[UIImage imageNamed:kRLCardBottom]];
    [_cardTopView setContentMode:UIViewContentModeTop];
    [_cardBottomView setContentMode:UIViewContentModeBottom];
    
    _cardTopView.autoresizingMask = UIViewAutoresizingNone;
    _cardCenterView.autoresizingMask = UIViewAutoresizingNone;
    _cardBottomView.autoresizingMask = UIViewAutoresizingNone;
    
    _cardCenterView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kRLCardBGUnit]];
    
    [_backgroundImageView addSubview:_cardTopView];
    [_backgroundImageView addSubview:_cardCenterView];
    [_backgroundImageView addSubview:_cardBottomView];
    
    [self addSubview:_backgroundImageView];

}

- (void)layoutSubviews
{
    [self sendSubviewToBack:_backgroundImageView];
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
//    CGImageRef topImageRef = [[UIImage imageNamed:kRLCardTop] CGImage];
//    CGContextDrawImage(currentContext, topRect, topImageRef);
//    
//
//    
//    CGRect bottomRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, HeightBottomView);
//    CGImageRef bottomImageRef = [[UIImage imageNamed:kRLCardBottom] CGImage];
//    CGContextDrawImage(currentContext, bottomRect, bottomImageRef);
//    
//    CGFloat centerHeight = rect.size.height - HeightTopView - HeightBottomView;
//    CGRect centerFrame = CGRectMake(rect.origin.x, HeightBottomView, rect.size.width, centerHeight);
//    
//    CGContextClipToRect(currentContext, centerFrame);
////    CGRect centerRect = CGRectMake(rect.origin.x, centerOriginY, rect.size.width, centerHeight);
//    UIImage *centerTileImage = [UIImage imageNamed:kRLCardBGUnit];
//    CGRect centerTileRect = CGRectMake(0.0, 0.0, centerTileImage.size.width, centerTileImage.size.height);
//    CGContextDrawTiledImage(currentContext, centerTileRect, centerTileImage.CGImage);
//    
////    NSLog(@"%f, %f, %f", topRect.origin.y, centerRect.origin.y, bottomRect.origin.y);
//}


@end
