//
//  MessageListViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-7-21.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "StackViewPageController.h"
#import "DMListTableViewController.h"

@interface MessageListViewController : StackViewPageController

@property (nonatomic, strong) DMListTableViewController *listTableViewController;

@end
