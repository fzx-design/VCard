//
//  BaseLayoutView.m
//  VCard
//
//  Created by 海山 叶 on 12-4-11.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "BaseLayoutView.h"
#import "ResourceList.h"
#import "ResourceProvider.h"
#import <QuartzCore/CATiledLayer.h>

#define CenterTileRect CGRectMake(0.0, 0.0, 1024, 62)

@implementation BaseLayoutView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
//        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kRLCastViewBGUnit]];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

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
    
    CGContextClipToRect(currentContext, rect);
    CGRect centerTileRect = CenterTileRect;
    CGContextDrawTiledImage(currentContext, centerTileRect, [ResourceProvider backgroundTileImageRef]);
}


@end
