//
//  SelfCommentTableViewController.h
//  VCard
//
//  Created by Gabriel Yeah on 12-6-24.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "RefreshableCoreDataTableViewController.h"

typedef enum {
    CommentsTableViewDataSourceCommentsToMe,
	CommentsTableViewDataSourceCommentsByMe,
    CommentsTableViewDataSourceCommentsOfStatus,
    CommentsTableViewDataSourceCommentsMentioningMe,
} CommentsTableViewDataSource;

@interface SelfCommentTableViewController : RefreshableCoreDataTableViewController {
    
    int _nextCursor;
}

@property(nonatomic, assign) CommentsTableViewDataSource dataSource;

@end
