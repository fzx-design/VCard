//
//  ShelfScrollView.m
//  VCard
//
//  Created by 海山 叶 on 12-7-4.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "ShelfScrollView.h"

@implementation ShelfScrollView

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
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.contentOffset.x < self.frame.size.width) {
        return nil;
    }
    for(UIView *subview in self.subviews) {
        CGPoint subPoint = [self convertPoint:point toView:subview];
        UIView *view = [subview hitTest:subPoint withEvent:event];
        if (view)
            return view;
    }

    return self;
}

@end
