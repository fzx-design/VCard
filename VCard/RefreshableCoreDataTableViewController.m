//
//  RefreshableCoreDataTableViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-5-29.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "RefreshableCoreDataTableViewController.h"
#import "UIView+Resize.h"

@interface RefreshableCoreDataTableViewController ()

@end

@implementation RefreshableCoreDataTableViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView resetWidth:384.0];
    _pullView = [[PullToRefreshView alloc] initWithScrollView:self.tableView];
    [_pullView setDelegate:self];
    
    _loadMoreView = [[LoadMoreView alloc] initWithScrollView:self.tableView];
    [_loadMoreView setDelegate:self];
    
    [self.tableView addSubview:_pullView];
    [self.tableView addSubview:_loadMoreView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)refresh
{
    //To override
}

- (void)loadMore
{
    //To override
}


#pragma mark - PullToRefreshViewDelegate
- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view
{
    [self refresh];
}

#pragma mark - LoadMoreViewDelegate
- (void)loadMoreViewShouldLoadMoreView:(LoadMoreView *)view
{
    [self loadMore];
}

@end
