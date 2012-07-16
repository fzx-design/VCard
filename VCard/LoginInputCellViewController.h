//
//  LoginInputCellViewController.h
//  VCard
//
//  Created by 王 紫川 on 12-7-10.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginCellViewController.h"

#define kNotificationNameLoginTextFieldShouldBeginEditing @"kNotificationNameLoginTextFieldShouldBeginEditing"
#define kNotificationNameLoginTextFieldShouldEndEditing @"kNotificationNameLoginTextFieldShouldEndEditing"
#define kNotificationNameLoginInfoAuthorized @"kNotificationNameLoginInfoAuthorized"

@interface LoginInputCellViewController : LoginCellViewController <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *userNameTextField;
@property (nonatomic, strong) IBOutlet UITextField *userPasswordTextField;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) IBOutlet UILabel *tooManyUsersLabel;
@property (nonatomic, strong) IBOutlet UIView *inputBgView;

- (IBAction)loginButtonClicked:(id)sender;

- (void)setTooManyUsers:(BOOL)tooMany;

@end
