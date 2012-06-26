//
//  SelfMentionViewController.h
//  VCard
//
//  Created by Gabriel Yeah on 12-6-26.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "StackViewPageController.h"
#import "ProfileStatusTableViewController.h"

@interface SelfMentionViewController : StackViewPageController

@property (nonatomic, strong) ProfileStatusTableViewController *statusTableViewController;

@end
