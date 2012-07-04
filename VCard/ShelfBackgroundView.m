//
//  ShelfBackgroundView.m
//  VCard
//
//  Created by 海山 叶 on 12-7-4.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "ShelfBackgroundView.h"

@implementation ShelfBackgroundView

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

- (void)initScrollView:(ShelfScrollView *)scrollView
{
    _scrollViewReference = scrollView;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (!CGRectContainsPoint(self.frame, point)) {
		return nil;
	}
    
    CGPoint subPoint = [self convertPoint:point toView:_scrollViewReference];
    UIView *view = [_scrollViewReference hitTest:subPoint withEvent:event];
    if (view) {
        return view;
    }
    
    for(UIView *subview in self.subviews) {
        CGPoint subPoint = [self convertPoint:point toView:subview];
        UIView *view = [subview hitTest:subPoint withEvent:event];
        if (view)
            return view;
    }
    
    return _scrollViewReference;
}

@end
