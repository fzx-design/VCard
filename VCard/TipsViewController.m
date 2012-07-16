//
//  TipsViewControllerler.m
//  VCard
//
//  Created by 王 紫川 on 12-7-12.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TipsViewController.h"
#import "UIApplication+Addition.h"
#import "UIView+Resize.h"
#import "UIView+Addition.h"

#define SHELF_TIPS_TEXT @"向右滑动可以打开快速阅读设置"
#define STACK_TIPS_TEXT @"将分页划出屏幕以关闭" 

#define SHELF_TIPS_VIEW_LANDSCAPE_CENTER    CGPointMake(512, 75)
#define SHELF_TIPS_VIEW_PORTRAIT_CENTER     CGPointMake(384, 75)
#define STACK_TIPS_VIEW_LANDSCAPE_CENTER    CGPointMake(792, 374)
#define STACK_TIPS_VIEW_PORTRAIT_CENTER     CGPointMake(576, 502)

@interface TipsViewController () {
    TipsViewControllerType _controllerType;
    BOOL _hasDismissed;
}

@end

@implementation TipsViewController

@synthesize tipsLabel = _tipsLabel;
@synthesize tipsView = _tipsView;

- (id)initWithType:(TipsViewControllerType)type {
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
    [self.view resetSize:[UIApplication sharedApplication].screenSize];
    
    if(_controllerType == TipsViewControllerTypeShelf) {
        self.tipsLabel.text = SHELF_TIPS_TEXT;
    } else if(_controllerType == TipsViewControllerTypeStack) {
        self.tipsLabel.text = STACK_TIPS_TEXT;
    }
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapScreen:)];
    [self.view addGestureRecognizer:tapGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didTapScreen:)];
    [self.view addGestureRecognizer:panGesture];
    
    [self.tipsView fadeIn];
    
    [self performSelector:@selector(dismissView) withObject:nil afterDelay:3.0f];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Dispose of any resources that can be recreated.
    self.tipsLabel = nil;
    self.tipsView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewWillLayoutSubviews {
    if(self.view.frame.size.width == 1024) {
        if(_controllerType == TipsViewControllerTypeShelf) {
            self.tipsView.center = SHELF_TIPS_VIEW_LANDSCAPE_CENTER;
        } else if(_controllerType == TipsViewControllerTypeStack) {
            self.tipsView.center = STACK_TIPS_VIEW_LANDSCAPE_CENTER;
        }
        
    } else if(self.view.frame.size.width == 768) {
        if(_controllerType == TipsViewControllerTypeShelf) {
            self.tipsView.center = SHELF_TIPS_VIEW_PORTRAIT_CENTER;
        } else if(_controllerType == TipsViewControllerTypeStack) {
            self.tipsView.center = STACK_TIPS_VIEW_PORTRAIT_CENTER;
        }
    }
}

- (void)dismissView {
    if(_hasDismissed)
        return;
    [UIApplication dismissModalViewControllerAnimated:NO];
    [self.view fadeOut];
    _hasDismissed = YES;
}

#pragma mark - Logic methods

- (void)didTapScreen:(UIGestureRecognizer *)gr {
    [self dismissView];
}

#pragma mark - UI methods

- (void)show {
    [UIApplication presentModalViewController:self animated:NO];
}

@end
