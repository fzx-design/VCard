//
//  LoginBgView.m
//  VCard
//
//  Created by 王 紫川 on 12-7-10.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "LoginBgView.h"
#import "UIApplication+Addition.h"
    
#define SCROLL_VIEW_LANDSCAPE_FRAME         CGRectMake(0, 40, 1024, 748 - 44)
#define SCROLL_VIEW_REAL_LANDSCAPE_FRAME    CGRectMake(256, 175, 512, 450)

#define SCROLL_VIEW_PORTRAIT_FRAME          CGRectMake(0, 40, 768, 1004 - 44)
#define SCROLL_VIEW_REAL_PORTRAIT_FRAME     CGRectMake(192, 225, 384, 450)

#define LOGIN_SCROOL_VIEW_TAG   2001

@implementation LoginBgView

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
    __block UIView *subview = [super hitTest:point withEvent:event];
    
    CGRect scrollViewFrame = [UIApplication isCurrentOrientationLandscape] ? SCROLL_VIEW_LANDSCAPE_FRAME : SCROLL_VIEW_PORTRAIT_FRAME;
    CGRect scrollViewRealFrame = [UIApplication isCurrentOrientationLandscape] ? SCROLL_VIEW_REAL_LANDSCAPE_FRAME : SCROLL_VIEW_REAL_PORTRAIT_FRAME;
    if (CGRectContainsPoint(scrollViewFrame, point)) {
        [[self subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIView *view = obj;
            if (view.tag == LOGIN_SCROOL_VIEW_TAG) {
                subview = view;
                *stop = YES;
            }
        }];
        if (CGRectContainsPoint(scrollViewRealFrame, point))
            subview = [subview hitTest:[subview convertPoint:point fromView:self] withEvent:event];
    }
    return subview;
}

@end
