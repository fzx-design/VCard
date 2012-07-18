//
//  ActionPopoverViewController.h
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 3/8/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActionPopoverViewController : UIViewController<UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *topBar;
@property (weak, nonatomic) IBOutlet UIView *centerBar;
@property (weak, nonatomic) IBOutlet UIImageView *bottomBar;

@property (readonly) CGFloat skew;
@property (readonly, nonatomic) CGFloat durationMultiplier;

- (void)setCropView:(UIView *)view cropPosY:(CGFloat)y;
- (void)handlePinch:(UIPinchGestureRecognizer *)gestureRecognizer;
- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer;

@end
