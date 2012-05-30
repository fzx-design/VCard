//
//  RefreshableCoreDataTableViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-5-29.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "PullToRefreshView.h"
#import "BaseLayoutView.h"

@interface RefreshableCoreDataTableViewController : CoreDataTableViewController <PullToRefreshViewDelegate, UIScrollViewDelegate, UITableViewDelegate> {
    PullToRefreshView *_pullView;
    
    BaseLayoutView *_backgroundViewA;
    BaseLayoutView *_backgroundViewB;
}

@property (nonatomic, retain) BaseLayoutView *backgroundViewA;
@property (nonatomic, retain) BaseLayoutView *backgroundViewB;

- (void)refresh;
- (void)resetTableViewLayout;

@end
