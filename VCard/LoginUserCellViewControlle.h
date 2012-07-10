//
//  LoginCellViewController.h
//  VCard
//
//  Created by 王 紫川 on 12-7-10.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginUserCellViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet UILabel *userNameLabel;
@property (nonatomic, strong) IBOutlet UIButton *deleteButton;

- (IBAction)didClickDeleteButton:(UIButton *)sender;
- (IBAction)didClickLoginButton:(UIButton *)sender;

@end
