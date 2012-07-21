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
#import "StackViewController.h"
#import "ProfileStatusTableViewCell.h"

@interface ActionPopoverGestureRecognizeView()

@end

@implementation ActionPopoverGestureRecognizeView

@synthesize delegate = _delegate;

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *result = [super hitTest:point withEvent:event];
    UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].rootViewController;
    RootViewController *rootVC = (RootViewController *)[nav topViewController];
    CastViewController *castVC = rootVC.castViewController;
    
    if(!castVC.stackViewController) {
        for(WaterflowCardCell *cardCell in castVC.waterflowView.subviews) {
            if([cardCell isKindOfClass:[WaterflowCardCell class]]) {
                CGPoint cardCellPoint = [self convertPoint:point toView:cardCell];
                if([cardCell pointInside:cardCellPoint withEvent:event] && cardCell.cardViewController.view.tag == ACTION_POPOVER_CONTAINER_VIEW) {
                    UIView *actionPopoverCenterBar = cardCell.cardViewController.actionPopoverViewController.centerBar;
                    CGPoint actionPopoverPoint = [cardCell convertPoint:cardCellPoint toView:actionPopoverCenterBar];
                    if([actionPopoverCenterBar pointInside:actionPopoverPoint withEvent:event]) {
                        //NSLog(@"action popover");
                        UIView *testView = [actionPopoverCenterBar hitTest:actionPopoverPoint withEvent:event];
                        if([testView isKindOfClass:[UIButton class]])
                            return testView;
                    }
                }
            }
        }
    } else {
        for(StackViewPageController *vc in castVC.stackViewController.controllerStack) {
            for(UITableView *tableView in vc.backgroundView.subviews) {
                CGPoint tableViewPoint = [self convertPoint:point toView:tableView];
                if(![tableView pointInside:tableViewPoint withEvent:event])
                    continue;
                
                if([tableView isKindOfClass:[UITableView class]]) {
                    for(ProfileStatusTableViewCell *tableViewCell in tableView.visibleCells) {
                        if(![tableViewCell isKindOfClass:[ProfileStatusTableViewCell class]])
                            break;
                        
                        if(tableViewCell.cardViewController.view.tag == ACTION_POPOVER_CONTAINER_VIEW) {
                            UIView *actionPopoverCenterBar = tableViewCell.cardViewController.actionPopoverViewController.centerBar;
                            CGPoint actionPopoverPoint = [tableView convertPoint:tableViewPoint toView:actionPopoverCenterBar];
                            if([actionPopoverCenterBar pointInside:actionPopoverPoint withEvent:event]) {
                                //NSLog(@"action popover in stack view");
                                UIView *testView = [actionPopoverCenterBar hitTest:actionPopoverPoint withEvent:event];
                                if([testView isKindOfClass:[UIButton class]])
                                    return testView;
                            }
                        }
                    }
                }
            }
        }
    }
    
    return result;
}

@end
