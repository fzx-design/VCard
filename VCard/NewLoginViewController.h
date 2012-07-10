//
//  NewLoginViewController.h
//  VCard
//
//  Created by 王 紫川 on 12-7-9.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataViewController.h"
#import "LoginCellViewController.h"
#import "LoginUserCellViewControlle.h"

@protocol NewLoginViewControllerDelegate;

@interface NewLoginViewController : CoreDataViewController <UIScrollViewDelegate, LoginUserCellViewControlle>

@property (nonatomic, strong) IBOutlet UIButton *registerButton;
@property (nonatomic, strong) IBOutlet UIView *bgView;
@property (nonatomic, strong) IBOutlet UIImageView *logoImageView;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) id<NewLoginViewControllerDelegate> delegate;

- (void)show;

- (IBAction)didClickRegisterButton:(UIButton *)sender;

@end

@protocol NewLoginViewControllerDelegate <NSObject>

- (void)loginViewController:(NewLoginViewController *)vc didSelectUser:(User *)user;

@end
