//
//  SelfCommentViewController.h
//  VCard
//
//  Created by Gabriel Yeah on 12-6-24.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "StackViewPageController.h"
#import "SelfCommentTableViewController.h"

@interface SelfCommentViewController : StackViewPageController

@property (nonatomic, strong) SelfCommentTableViewController *commentToMeTableViewController;
@property (nonatomic, strong) SelfCommentTableViewController *commentByMeTableViewController;
@property (nonatomic, weak) IBOutlet UIButton *toMeButton;
@property (nonatomic, weak) IBOutlet UIButton *byMeButton;

- (IBAction)didClickSwitchToMeButton:(UIButton *)sender;
- (IBAction)didClickSwitchByMeButton:(UIButton *)sender;

@end
