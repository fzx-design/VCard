//
//  SelfMentionViewController.h
//  VCard
//
//  Created by Gabriel Yeah on 12-6-26.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "StackViewPageController.h"
#import "ProfileStatusTableViewController.h"
#import "SelfCommentTableViewController.h"

@interface SelfMentionViewController : StackViewPageController

@property (nonatomic, strong) ProfileStatusTableViewController *statusTableViewController;
@property (nonatomic, strong) SelfCommentTableViewController *commentTableViewController;
@property (nonatomic, weak) IBOutlet UIButton *checkCommentButton;
@property (nonatomic, weak) IBOutlet UIButton *checkStatusButton;

- (IBAction)didClickCheckCommentButton:(id)sender;
- (IBAction)didClickCheckStatusButton:(id)sender;

@end
