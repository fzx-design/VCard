//
//  NewLoginViewController.m
//  VCard
//
//  Created by 王 紫川 on 12-7-9.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "NewLoginViewController.h"
#import "UIApplication+Addition.h"
#import <QuartzCore/QuartzCore.h>

@interface NewLoginViewController ()

@end

@implementation NewLoginViewController

@synthesize registerButton = _registerButton;
@synthesize bgView = _bgView;

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
    [self configureUI];
    [self viewAppearAnimation];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Dispose of any resources that can be recreated.
    self.bgView = nil;
    self.registerButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - UI methods

- (void)configureUI {
    [ThemeResourceProvider configButtonPaperLight:self.registerButton];
}

- (void)show {
    [UIApplication presentModalViewController:self animated:NO duration:0.7f];
}

#pragma mark - Animations

- (void)viewAppearAnimation {
    __block CGRect frame = self.view.frame;
    frame.origin = CGPointMake(0, -frame.size.height);
    self.view.frame = frame;
    [UIView animateWithDuration:0.7f animations:^{
        frame.origin = CGPointMake(0, 0);
        self.view.frame = frame;
    }];
}

#pragma mark - IBActions 

- (IBAction)didClickRegisterButton:(UIButton *)sender {
    __block CGRect frame = self.view.frame;
    frame.origin = CGPointMake(0, 0);
    self.view.frame = frame;
    [UIView animateWithDuration:0.7f animations:^{
        frame.origin = CGPointMake(0, -frame.size.height);
        self.view.frame = frame;
    } completion:^(BOOL finished) {
    }];
    [UIApplication dismissModalViewControllerAnimated:NO duration:0.7f];
}

@end
