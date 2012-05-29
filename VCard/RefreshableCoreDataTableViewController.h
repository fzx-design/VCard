//
//  RefreshableCoreDataTableViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-5-29.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "PullToRefreshView.h"

@interface RefreshableCoreDataTableViewController : CoreDataTableViewController <PullToRefreshViewDelegate> {
    PullToRefreshView *_pullView;
}

- (void)refresh;
- (void)resetFrame:(CGRect)frame;

@end
