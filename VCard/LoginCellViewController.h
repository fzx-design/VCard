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

@interface LoginCellViewController : CoreDataViewController

@property (nonatomic, strong) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet UIImageView *avatarBgImageView;
@property (nonatomic, strong) IBOutlet UIImageView *gloomImageView;
@property (nonatomic, strong) IBOutlet UIButton *loginButton;
@property (nonatomic, weak) id<LoginCellViewControllerDelegate> delegate;

- (void)loginUsingAccount:(NSString *)account
                 password:(NSString *)password
               completion:(void (^)(BOOL succeeded))compeltion;

@end

@protocol LoginCellViewControllerDelegate <NSObject>

- (void)loginCellWillLoginUser;
- (void)loginCellDidFailLoginUser;
- (void)loginCellDidLoginUser:(User *)user;
- (void)loginCellDidDeleteUser:(User *)user;

@end