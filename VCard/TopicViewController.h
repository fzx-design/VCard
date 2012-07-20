//
//  TopicViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-7-4.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "StackViewPageController.h"
#import "ProfileStatusTableViewController.h"
#import "PostViewController.h"

@interface TopicViewController : StackViewPageController <PostViewControllerDelegate>

@property (nonatomic, strong) ProfileStatusTableViewController *statusTableViewController;
@property (nonatomic, weak) IBOutlet UILabel *topicTitleLabel;
@property (nonatomic, weak) IBOutlet UIButton *followTopicButton;
@property (nonatomic, weak) IBOutlet UIButton *postTopicButton;
@property (nonatomic, strong) NSString *searchKey;

- (IBAction)didClickFollowTopicButton:(UIButton *)sender;
- (IBAction)didClickPostTopicButton:(UIButton *)sender;

@end
