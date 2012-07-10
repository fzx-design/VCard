//
//  LoginCell.m
//  VCard
//
//  Created by 海山 叶 on 12-4-11.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "LoginUserCellViewControlle.h"
#import <QuartzCore/QuartzCore.h>
#import "ResourceList.h"
#import "CastViewController.h"
#import "WBClient.h"

#define CornerRadius 175 / 2

@interface LoginUserCellViewController ()

@end

@implementation LoginUserCellViewController

@synthesize avatarImageView = _avatarImageView;
@synthesize userNameLabel = _userNameLabel;
@synthesize deleteButton = _deleteButton;

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
    _avatarImageView.layer.masksToBounds = YES;
    _avatarImageView.layer.cornerRadius = CornerRadius;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.deleteButton = nil;
    self.userNameLabel = nil;
    self.avatarImageView = nil;
}

#pragma mark - IBActions

- (IBAction)didClickDeleteButton:(UIButton *)sender {
    
}

- (IBAction)didClickLoginButton:(UIButton *)sender {
    
}

@end
