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
+ (void)dismissModalViewController;

@end