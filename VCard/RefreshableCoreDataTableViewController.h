//
//  RefreshableCoreDataTableViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-5-29.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "PullToRefreshView.h"
#import "LoadMoreView.h"
#import "BaseLayoutView.h"

@class User;

@interface RefreshableCoreDataTableViewController : CoreDataTableViewController <PullToRefreshViewDelegate, LoadMoreViewDelegate, UIScrollViewDelegate, UITableViewDelegate> {
    
    int _stackPageIndex;
    PullToRefreshView *_pullView;
    LoadMoreView *_loadMoreView;
    
    User *_user;
    BOOL _hasMoreViews;
}

@property (nonatomic, assign) int stackPageIndex;
@property (nonatomic, strong) User *user;

- (void)refresh;
- (void)loadMore;
- (void)adjustBackgroundView;

@end
