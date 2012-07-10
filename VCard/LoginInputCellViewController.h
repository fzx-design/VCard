//
//  LoginInputCellViewController.h
//  VCard
//
//  Created by 王 紫川 on 12-7-10.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginCellViewController.h"

@protocol LoginInputCellViewControllerDelegate;

#define kNotificationNameLoginTextFieldShouldBeginEditing @"kNotificationNameLoginTextFieldShouldBeginEditing"
#define kNotificationNameLoginTextFieldShouldEndEditing @"kNotificationNameLoginTextFieldShouldEndEditing"
#define kNotificationNameLoginInfoAuthorized @"kNotificationNameLoginInfoAuthorized"

@interface LoginInputCellViewController : LoginCellViewController <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *userNameTextField;
@property (nonatomic, strong) IBOutlet UITextField *userPasswordTextField;
@property (nonatomic, weak) id<LoginInputCellViewControllerDelegate> delegate;

- (IBAction)loginButtonClicked:(id)sender;

@end

@protocol LoginInputCellViewControllerDelegate <NSObject>

- (void)loginCell:(LoginInputCellViewController *)vc didLoginUser:(User *)user;

@end
