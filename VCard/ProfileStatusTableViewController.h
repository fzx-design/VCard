//
//  ProfileStatusTableViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-5-31.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "RefreshableCoreDataTableViewController.h"

typedef enum {
    StatusTableViewControllerTypeUserStatus,
    statusTableViewControllerTypeMentionStatus,
} StatusTableViewControllerType;

@interface ProfileStatusTableViewController : RefreshableCoreDataTableViewController {
    
}

@property (nonatomic, assign) StatusTableViewControllerType type;

- (void)refresh;
- (void)loadMore;

@end
