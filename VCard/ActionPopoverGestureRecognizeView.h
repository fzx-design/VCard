//
//  ActionPopoverGestureRecognizeView.h
//  VCard
//
//  Created by 王 紫川 on 12-7-19.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ACTION_POPOVER_CONTAINER_VIEW   3001

@protocol ActionPopoverGestureRecognizeViewDelegate;

@interface ActionPopoverGestureRecognizeView : UIView

@property (nonatomic, weak) IBOutlet id<ActionPopoverGestureRecognizeViewDelegate> delegate;

@end

@protocol ActionPopoverGestureRecognizeViewDelegate <NSObject>

- (void)actionPopoverGestureRecognizeViewDidDetectDismissTouch;

@end
