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

typedef enum {
    LoginViewControllerTypeDefault = 0,
    LoginViewControllerTypeDeleteCurrentUser = 1,
    LoginViewControllerTypeCreateNewUser = 2,
} LoginViewControllerType;


@interface LoginViewController : CoreDataViewController <UIScrollViewDelegate, LoginCellViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIButton *registerButton;
@property (nonatomic, weak) IBOutlet UIView *bgView;
@property (nonatomic, weak) IBOutlet UIImageView *logoImageView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

- (void)show;

- (id)initWithType:(LoginViewControllerType)type;

- (IBAction)didClickRegisterButton:(UIButton *)sender;

@end
