//
//  PostRootView.m
//  VCard
//
//  Created by 紫川 王 on 12-6-7.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "PostRootView.h"

@implementation PostRootView

@synthesize observingViewTag = _observingViewTag;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *subview = [super hitTest:point withEvent:event];
    if (self.observingViewTag != PostRootViewSubviewTagNone) {
        if (subview.tag != self.observingViewTag &&
           subview.superview.tag != self.observingViewTag && 
           subview.superview.superview.tag != self.observingViewTag &&
           subview.superview.superview.superview.tag != self.observingViewTag) {
            [self.delegate postRootView:self didObserveTouchOtherView:subview];
        }
    }
    return subview;
}

@end
