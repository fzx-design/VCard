//
//  MultiInterfaceOrientationViewController.h
//  VCard
//
//  Created by 王 紫川 on 12-6-26.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MultiInterfaceOrientationViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *subViewControllers;

- (void)loadInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (void)loadViewControllerWithInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end
