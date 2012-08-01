//
//  MessageListViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-7-21.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "MessageListViewController.h"

@interface MessageListViewController ()

@end

@implementation MessageListViewController

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
    [self.backgroundView addSubview:self.listTableViewController.view];
    [self.topShadowImageView resetOriginY:[self frameForTableView].origin.y];
    [self.topShadowImageView resetOriginX:0.0];
    [self.view addSubview:self.topShadowImageView];
}

- (void)viewDidUnload
{
    _listTableViewController = nil;
    [super viewDidUnload];
}

- (void)clearPage
{
    [_listTableViewController.view removeFromSuperview];
    _listTableViewController = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_listTableViewController viewWillDisappear:NO];
}

- (void)initialLoad
{
    [self.listTableViewController refresh];
}

- (void)showWithPurpose
{
    [_listTableViewController refresh];
}

#pragma mark - Properties
- (CGRect)frameForTableView
{
    CGFloat originY = 50;
    CGFloat height = self.view.frame.size.height - originY;
    return CGRectMake(24.0, originY, 382.0, height);
}

- (DMListTableViewController *)listTableViewController
{
    if (!_listTableViewController) {
        _listTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DMListTableViewController"];
        _listTableViewController.view.frame = [self frameForTableView];
        _listTableViewController.tableView.frame = [self frameForTableView];
    }
    return _listTableViewController;
}

@end
