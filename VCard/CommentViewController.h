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

@interface CommentViewController : StackViewPageController

@property (nonatomic, strong) Status *status;
@property (nonatomic, strong) ProfileCommentTableViewController *commentTableViewController;

@end
