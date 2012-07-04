//
//  SearchViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-7-4.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "StackViewPageController.h"
#import "SearchTableViewController.h"

@interface SearchViewController : StackViewPageController <UITextFieldDelegate>

@property (nonatomic, strong) SearchTableViewController *searchTableViewController;
@property (nonatomic, strong) IBOutlet UITextField *textField;

@end
