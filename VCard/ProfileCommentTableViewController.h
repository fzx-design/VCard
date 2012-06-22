//
//  ProfileCommentTableViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-5-31.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "RefreshableCoreDataTableViewController.h"
#import "Status.h"

@interface ProfileCommentTableViewController : RefreshableCoreDataTableViewController {
    int _nextCursor;
    int _page;
    BOOL _sourceChanged;
}

@property (nonatomic, strong) Status *status;
@property (nonatomic, assign) BOOL filterByAuthor;

- (void)changeSource;

@end
