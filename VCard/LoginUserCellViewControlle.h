//
//  LoginCellViewController.h
//  VCard
//
//  Created by 王 紫川 on 12-7-10.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@protocol LoginUserCellViewControllerDelegate;

@interface LoginUserCellViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet UILabel *userNameLabel;
@property (nonatomic, strong) IBOutlet UIButton *deleteButton;
@property (nonatomic, weak) id<LoginUserCellViewControllerDelegate> delegate;

- (id)initWithUser:(User *)user;

- (IBAction)didClickDeleteButton:(UIButton *)sender;
- (IBAction)didClickLoginButton:(UIButton *)sender;

@end

@protocol LoginUserCellViewControllerDelegate <NSObject>

- (void)loginUserCell:(LoginUserCellViewController *)vc didSelectUser:(User *)user;
- (void)loginUserCell:(LoginUserCellViewController *)vc didDeleteUser:(User *)user;

@end
