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

@interface RefreshableCoreDataTableViewController : CoreDataTableViewController <PullToRefreshViewDelegate, LoadMoreViewDelegate, UIScrollViewDelegate, UITableViewDelegate> {
    
    PullToRefreshView *_pullView;
    LoadMoreView *_loadMoreView;
}

- (void)refresh;
- (void)loadMore;

@end
