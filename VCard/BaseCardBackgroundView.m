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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}


- (void)resetHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
    
    [self setNeedsDisplay];
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

    CGContextDrawImage(currentContext, topRect, [ResourceProvider topImageRef]);
    
    
    CGRect bottomRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, HeightBottomView);
    CGContextDrawImage(currentContext, bottomRect, [ResourceProvider bottomImageRef]);
    
    CGFloat centerHeight = rect.size.height - HeightTopView - HeightBottomView;
    CGRect centerFrame = CGRectMake(rect.origin.x, HeightBottomView, rect.size.width, centerHeight);
    
    CGContextClipToRect(currentContext, centerFrame);
    CGRect centerTileRect = CenterTileRect;
    CGContextDrawTiledImage(currentContext, centerTileRect, [ResourceProvider centerTileImageRef]);
    
}




@end
