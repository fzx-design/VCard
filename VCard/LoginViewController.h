//
//  LoginViewController.h
//  VCard
//
//  Created by 王 紫川 on 12-7-9.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataViewController.h"
#import "LoginCellViewController.h"


@interface LoginViewController : CoreDataViewController <UIScrollViewDelegate, LoginCellViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UIButton *registerButton;
@property (nonatomic, strong) IBOutlet UIView *bgView;
@property (nonatomic, strong) IBOutlet UIImageView *logoImageView;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

- (void)show;

- (IBAction)didClickRegisterButton:(UIButton *)sender;
- (IBAction)didClickLogoutButton:(UIButton *)sender;

@end
