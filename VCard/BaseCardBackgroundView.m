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
        
//        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kRLCardBGUnit]];
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(currentContext, 0, rect.size.height);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    
    CGRect topRect = CGRectMake(rect.origin.x, rect.size.height - HeightTopView, rect.size.width,
                                HeightTopView);
    CGImageRef topImageRef = [[UIImage imageNamed:kRLCardTop] CGImage];
    CGContextDrawImage(currentContext, topRect, topImageRef);
    

    
    CGRect bottomRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, HeightBottomView);
    CGImageRef bottomImageRef = [[UIImage imageNamed:kRLCardBottom] CGImage];
    CGContextDrawImage(currentContext, bottomRect, bottomImageRef);
    
    CGFloat centerOriginY = rect.origin.y + HeightBottomView;
    CGFloat centerHeight = rect.size.height - HeightTopView - HeightBottomView;
    CGRect centerFrame = CGRectMake(rect.origin.x, HeightBottomView, rect.size.width, centerHeight);
    
    CGContextClipToRect(currentContext, centerFrame);
//    CGRect centerRect = CGRectMake(rect.origin.x, centerOriginY, rect.size.width, centerHeight);
    UIImage *centerTileImage = [UIImage imageNamed:kRLCardBGUnit];
    CGRect centerTileRect = CGRectMake(0.0, 0.0, centerTileImage.size.width, centerTileImage.size.height);
    CGContextDrawTiledImage(currentContext, centerTileRect, centerTileImage.CGImage);
    
//    NSLog(@"%f, %f, %f", topRect.origin.y, centerRect.origin.y, bottomRect.origin.y);
}


@end
