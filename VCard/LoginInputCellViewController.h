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

<<<<<<< HEAD
@property (nonatomic, strong) IBOutlet UITextField *userNameTextField;
@property (nonatomic, strong) IBOutlet UITextField *userPasswordTextField;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) IBOutlet UILabel *tooManyUsersLabel;
@property (nonatomic, strong) IBOutlet UIView *inputBgView;
=======
@property (nonatomic, weak) IBOutlet UITextField *userNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *userPasswordTextField;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
>>>>>>> 将view controller的iboutlet全改造为weak

- (IBAction)loginButtonClicked:(id)sender;

- (void)setTooManyUsers:(BOOL)tooMany;

@end
