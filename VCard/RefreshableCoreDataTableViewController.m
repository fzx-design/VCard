//
//  RefreshableCoreDataTableViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-5-29.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "RefreshableCoreDataTableViewController.h"

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
    _pullView = [[PullToRefreshView alloc] initWithScrollView:(UIScrollView *)self.tableView];
    [_pullView setDelegate:self];
    [self.tableView addSubview:_pullView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cell_large_bg.png"]];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)refresh
{
    //To override
}

#pragma mark - PullToRefreshViewDelegate
- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view
{
    [self refresh];
}
@end
