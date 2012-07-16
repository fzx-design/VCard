//
//  ErrorIndicatorViewControllerler.m
//  VCard
//
//  Created by 王 紫川 on 12-7-12.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "ErrorIndicatorViewController.h"
#import "UIApplication+Addition.h"
#import "UIView+Resize.h"
#import "UIView+Addition.h"

#define SHELF_TIPS_TEXT @"向右滑动可以打开快速阅读设置"
#define STACK_TIPS_TEXT @"将分页划出屏幕以关闭" 

@interface ErrorIndicatorViewController () {
    ErrorIndicatorViewControllerType _controllerType;
    BOOL _hasDismissed;
}

@end

@implementation ErrorIndicatorViewController

@synthesize errorBgView = _errorBgView;
@synthesize errorImageView = _errorImageView;
@synthesize errorLabel = _errorLabel;
@synthesize refreshIndicator = _refreshIndicator;

- (id)initWithType:(ErrorIndicatorViewControllerType)type {
    self = [super init];
    if(self) {
        _controllerType = type;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.frame = CGRectMake(0, 0, [UIApplication screenWidth], [UIApplication screenHeight]);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Dispose of any resources that can be recreated.
    self.errorBgView = nil;
    self.errorImageView = nil;
    self.errorLabel = nil;
    self.refreshIndicator = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
