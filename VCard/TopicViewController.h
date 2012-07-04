//
//  TopicViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-7-4.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "StackViewPageController.h"
#import "ProfileStatusTableViewController.h"

@interface TopicViewController : StackViewPageController

@property (nonatomic, strong) ProfileStatusTableViewController *statusTableViewController;
@property (nonatomic, strong) IBOutlet UILabel *topicTitleLabel;
@property (nonatomic, strong) NSString *searchKey;

@end
