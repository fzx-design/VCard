//
//  ProfileCommentTableViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-5-31.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "RefreshableCoreDataTableViewController.h"
#import "ProfileCommentTableViewCell.h"
#import "Status.h"

typedef enum {
    CommentTableViewControllerTypeComment,
    CommentTableViewControllerTypeRepost,
} CommentTableViewControllerType;

@class ProfileCommentStatusTableCell;
@class ProfileCommentTableViewCell;

@interface ProfileCommentTableViewController : RefreshableCoreDataTableViewController

@property (nonatomic, assign) BOOL filterByAuthor;
@property (nonatomic, strong) Status *status;
@property (nonatomic, assign) CommentTableViewControllerType type;
@property (nonatomic, strong) ProfileCommentStatusTableCell *headerViewCell;

- (void)changeSource;
- (void)setUpHeaderView;

@end
