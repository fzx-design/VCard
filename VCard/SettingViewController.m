//
//  SettingViewController.m
//  VCard
//
//  Created by 王 紫川 on 12-7-12.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingRootViewController.h"
#import "UIApplication+Addition.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+Resize.h"

@interface SettingViewController ()

@property (nonatomic, strong) SettingRootViewController *settingRootViewController;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, readonly) CGPoint rootViewCenter;
@property (nonatomic, readonly) CGPoint shadowViewCenter;

@end

@implementation SettingViewController

@synthesize shadowImageView = _shadowImageView;

@synthesize settingRootViewController = _settingRootViewController;
@synthesize navigationController = _navigationController;

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
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.settingRootViewController];
    nav.view.frame = self.settingRootViewController.view.frame;
    nav.view.center = self.rootViewCenter;
    self.navigationController = nav;
    
    UIEdgeInsets insets = UIEdgeInsetsMake(12.0f, 16.0f, 20.0f, 16.0f);
    self.shadowImageView.image = [[UIImage imageNamed:@"settings_shadow"] resizableImageWithCapInsets:insets];
    self.shadowImageView.center = self.shadowViewCenter;
    
    [self.view addSubview:nav.view];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Dispose of any resources that can be recreated.
    self.shadowImageView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Logic methods 

- (CGPoint)rootViewCenter {
    return CGPointMake(self.view.center.x, self.view.center.y - 32);
}

- (CGPoint)shadowViewCenter {
    return CGPointMake(self.rootViewCenter.x, self.rootViewCenter.y + 4);
}

- (void)setSettingRootViewController:(SettingRootViewController *)settingRootViewController {
    [_settingRootViewController.view removeFromSuperview];
    _settingRootViewController = settingRootViewController;
}

- (SettingRootViewController *)settingRootViewController {
    if(_settingRootViewController == nil) {
        _settingRootViewController = [[SettingRootViewController alloc] init];
    }
    return _settingRootViewController;
}

#pragma mark - UI methods 

- (void)show {
    [UIApplication presentModalViewController:self animated:YES];
}

- (void)viewWillLayoutSubviews {
    self.navigationController.view.center = self.rootViewCenter;
    self.shadowImageView.center = self.shadowViewCenter;
}

@end
