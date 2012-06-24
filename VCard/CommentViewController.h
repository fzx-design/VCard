//
//  CommentViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-5-31.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "StackViewPageController.h"
#import "ProfileCommentTableViewController.h"
#import "Status.h"
#import "PostViewController.h"

@interface CommentViewController : StackViewPageController <PostViewControllerDelegate>

@property (nonatomic, strong) Status *status;
@property (nonatomic, strong) ProfileCommentTableViewController *commentTableViewController;
@property (nonatomic, strong) IBOutlet UIButton *changeSourceButton;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIButton *commentButton;

- (IBAction)didClickChangeSourceButton:(UIButton *)sender;
- (IBAction)didClickCommentButton:(UIButton *)sender;

@end
