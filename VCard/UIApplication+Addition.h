//
//  UIApplication+Addition.h
//  VCard
//
//  Created by 紫川 王 on 12-5-26.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MODAL_APPEAR_ANIMATION_DEFAULT_DURATION (0.3f)

@interface UIApplication (Addition)

@property (nonatomic, readonly) CGSize screenSize;
@property (nonatomic, readonly) UIViewController *rootViewController;

@property (nonatomic, readonly) UIViewController *topModalViewController;

+ (void)presentModalViewController:(UIViewController *)vc animated:(BOOL)animated;
+ (void)presentModalViewController:(UIViewController *)vc animated:(BOOL)animated duration:(NSTimeInterval)duration;

/* If pass NO as animated parameter, the view of vc will 
 not be removed from its super view automatically. */ 
+ (void)dismissModalViewControllerAnimated:(BOOL)animated;
+ (void)dismissModalViewControllerAnimated:(BOOL)animated duration:(NSTimeInterval)duration;
+ (void)dismissModalViewController:(UIViewController *)vc animated:(BOOL)animated duration:(NSTimeInterval)duration;

+ (BOOL)isRetinaDisplayiPad;
+ (CGFloat)heightExcludingTopBar;
+ (CGFloat)screenWidth;
+ (CGFloat)screenHeight;
+ (BOOL)isCurrentOrientationLandscape;
+ (UIInterfaceOrientation)currentOppositeInterface;
+ (UIInterfaceOrientation)currentInterface;
+ (void)relayoutRootViewController;

+ (UIPopoverController *)getAlbumImagePickerFromButton:(UIButton *)button delegate:(id)delegate;
+ (UIPopoverController *)showAlbumImagePickerFromButton:(UIButton *)button delegate:(id)delegate;

@end
