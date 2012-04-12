//
//  UserSelectionCellViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-4-11.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserSelectionCellViewController : UIViewController {
    UIImageView * _avatorImageView;
    UITextField * _userNameTextField;
    UITextField * _userPasswordTextField;
}

@property (nonatomic, strong) IBOutlet UIImageView *avatorImageView;
@property (nonatomic, strong) IBOutlet UITextField *userNameTextField;
@property (nonatomic, strong) IBOutlet UITextField *userPasswordTextField;

@end
