//
//  LoginCellViewController.h
//  VCard
//
//  Created by 王 紫川 on 12-7-10.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataViewController.h"

@protocol LoginCellViewControllerDelegate;

#define kNotificationNameLoginTextFieldShouldBeginEditing @"kNotificationNameLoginTextFieldShouldBeginEditing"
#define kNotificationNameLoginTextFieldShouldEndEditing @"kNotificationNameLoginTextFieldShouldEndEditing"
#define kNotificationNameLoginInfoAuthorized @"kNotificationNameLoginInfoAuthorized"

@interface LoginCellViewController : CoreDataViewController <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet UITextField *userNameTextField;
@property (nonatomic, strong) IBOutlet UITextField *userPasswordTextField;
@property (nonatomic, strong) IBOutlet UIButton *loginButton;
@property (nonatomic, weak) id<LoginCellViewControllerDelegate> delegate;

@end

@protocol LoginCellViewControllerDelegate <NSObject>

- (void)loginCell:(LoginCellViewController *)vc didLoginUser:(User *)user;

@end
