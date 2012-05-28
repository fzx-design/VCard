//
//  UserProfileViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-5-28.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "StackViewPageController.h"

@interface UserProfileViewController : StackViewPageController

@property (nonatomic, strong) IBOutlet UIButton *testButton;

- (IBAction)createNewStackPage:(id)sender;

@end
