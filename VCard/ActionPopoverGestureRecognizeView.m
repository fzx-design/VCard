//
//  ActionPopoverGestureRecognizeView.m
//  VCard
//
//  Created by 王 紫川 on 12-7-19.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "ActionPopoverGestureRecognizeView.h"
#import "UIApplication+Addition.h"
#import "RootViewController.h"
#import "WaterflowCardCell.h"

@implementation ActionPopoverGestureRecognizeView

@synthesize delegate = _delegate;

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *result = [super hitTest:point withEvent:event];
    UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].rootViewController;
    RootViewController *rootVC = (RootViewController *)[nav topViewController];
    
    for(WaterflowCardCell *cardCell in rootVC.castViewController.waterflowView.subviews) {
        if([cardCell isKindOfClass:[WaterflowCardCell class]]) {
            CGPoint cardCellPoint = [self convertPoint:point toView:cardCell];
            if([cardCell pointInside:cardCellPoint withEvent:event] && cardCell.cardViewController.view.tag == ACTION_POPOVER_CONTAINER_VIEW) {
                UIView *actionPopoverCenterBar = cardCell.cardViewController.actionPopoverViewController.centerBar;
                CGPoint actionPopoverPoint = [cardCell convertPoint:cardCellPoint toView:actionPopoverCenterBar];
                if([actionPopoverCenterBar pointInside:actionPopoverPoint withEvent:event]) {
                    NSLog(@"action popover");
                    return [actionPopoverCenterBar hitTest:actionPopoverPoint withEvent:event];
                }
            }
        }
    }
    
    return result;
}

@end
