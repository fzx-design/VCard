//
//  LoginCellViewController.m
//  VCard
//
//  Created by 王 紫川 on 12-7-10.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "LoginCellViewController.h"
#import <QuartzCore/QuartzCore.h>

#define CornerRadius 175 / 2

@interface LoginCellViewController ()

@end

@implementation LoginCellViewController

@synthesize avatarImageView = _avatarImageView;
@synthesize loginButton = _loginButton;
@synthesize gloomImageView = _gloomImageView;
@synthesize avatarBgImageView = _avatarBgImageView;

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
	// Do any additional setup after loading the view.
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.cornerRadius = CornerRadius;
    
    self.avatarBgImageView.layer.masksToBounds = YES;
    self.avatarBgImageView.layer.cornerRadius = CornerRadius;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Dispose of any resources that can be recreated.
    self.avatarImageView = nil;
    self.loginButton = nil;
    self.gloomImageView = nil;
    self.avatarBgImageView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
