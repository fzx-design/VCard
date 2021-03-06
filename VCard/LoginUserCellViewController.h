//
//  LoginInputCellViewController.h
//  VCard
//
//  Created by 王 紫川 on 12-7-10.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginCellViewController.h"

@protocol LoginUserCellViewControllerDelegate;

@interface LoginUserCellViewController : LoginCellViewController <UIActionSheetDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;

- (id)initWithUser:(User *)user;

- (IBAction)didClickDeleteButton:(UIButton *)sender;
- (IBAction)didClickLoginButton:(UIButton *)sender;

@end
