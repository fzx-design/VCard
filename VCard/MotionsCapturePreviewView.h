//
//  MotionsCapturePreviewView.h
//  VCard
//
//  Created by 紫川 王 on 12-4-13.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MotionsCapturePreviewViewDelegate;

@interface MotionsCapturePreviewView : UIView

@property (nonatomic, weak) IBOutlet id<MotionsCapturePreviewViewDelegate> delegate;

@end

@protocol MotionsCapturePreviewViewDelegate <NSObject>

- (void)didCreateInterestPoint:(CGPoint)focusPoint;

@end