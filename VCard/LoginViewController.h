//
//  LoginViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-4-11.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataViewController.h"
#import "BaseLayoutView.h"
#import "EasyTableView.h"
#import "UserSelectionCellViewController.h"

@interface LoginViewController : CoreDataViewController <EasyTableViewDelegate> {
    UIImageView * _logoImageView;
    EasyTableView *_userSelectionTableView;
    UserSelectionCellViewController *_currentUserCell;
    
    UIInterfaceOrientation _currentOrientation;
    BOOL _isEditingTextfield;
}

@property (nonatomic, strong) IBOutlet UIImageView *logoImageView;
@property (nonatomic, strong) EasyTableView *userSelectionTableView;
@property (nonatomic, strong) UserSelectionCellViewController *currentUserCell;

@end
