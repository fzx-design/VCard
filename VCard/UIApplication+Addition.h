//
//  UIApplication+Addition.h
//  VCard
//
//  Created by 紫川 王 on 12-5-26.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (Addition)

@property (nonatomic, readonly) CGSize screenSize;
@property (nonatomic, readonly) UIViewController *rootViewController;

+ (void)presentModalViewController:(UIViewController *)vc animated:(BOOL)animated;

/* If pass NO as animated parameter, the view of vc will 
 not be removed from its super view automatically. */ 
+ (void)dismissModalViewControllerAnimated:(BOOL)animated;
+ (BOOL)isRetinaDisplayiPad;
+ (CGFloat)heightExcludingTopBar;

@end
