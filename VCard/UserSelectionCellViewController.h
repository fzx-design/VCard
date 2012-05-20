//
//  UserSelectionCellViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-4-11.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kNotificationNameLoginTextFieldShouldBeginEditing @"kNotificationNameLoginTextFieldShouldBeginEditing"
#define kNotificationNameLoginTextFieldShouldEndEditing @"kNotificationNameLoginTextFieldShouldEndEditing"
#define kNotificationNameLoginInfoAuthorized @"kNotificationNameLoginInfoAuthorized"

@interface UserSelectionCellViewController : UIViewController <UITextFieldDelegate> {
    UIImageView * _avatarImageView;
    UIImageView * _avatarImageViewBG;
    UITextField * _userNameTextField;
    UITextField * _userPasswordTextField;
    UIButton *_loginButton;
}

@property (nonatomic, strong) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet UIImageView *avatarImageViewBG;
@property (nonatomic, strong) IBOutlet UITextField *userNameTextField;
@property (nonatomic, strong) IBOutlet UITextField *userPasswordTextField;
@property (nonatomic, strong) IBOutlet UIButton *loginButton;

@end
