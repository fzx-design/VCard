//
//  NewLoginViewController.h
//  VCard
//
//  Created by 王 紫川 on 12-7-9.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewLoginViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIButton *registerButton;
@property (nonatomic, strong) IBOutlet UIView *bgView;

- (void)show;

- (IBAction)didClickRegisterButton:(UIButton *)sender;

@end
