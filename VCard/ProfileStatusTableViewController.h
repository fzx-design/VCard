//
//  ProfileStatusTableViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-5-31.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "RefreshableCoreDataTableViewController.h"

@interface ProfileStatusTableViewController : RefreshableCoreDataTableViewController {
    BaseLayoutView *_backgroundViewA;
    BaseLayoutView *_backgroundViewB;
}

@property (nonatomic, retain) BaseLayoutView *backgroundViewA;
@property (nonatomic, retain) BaseLayoutView *backgroundViewB;

- (void)refresh;
- (void)loadMore;

@end
