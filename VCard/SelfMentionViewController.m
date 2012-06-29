//
//  SelfMentionViewController.m
//  VCard
//
//  Created by Gabriel Yeah on 12-6-26.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "SelfMentionViewController.h"

@interface SelfMentionViewController ()

@end

@implementation SelfMentionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initialLoad
{
    [self.statusTableViewController refresh];
}

- (void)refresh
{
    [self.statusTableViewController refresh];
}

- (void)enableScrollToTop
{
    self.statusTableViewController.tableView.scrollsToTop = YES;
}

- (void)disableScrollToTop
{
    self.statusTableViewController.tableView.scrollsToTop = NO;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.topShadowImageView resetOrigin:[self frameForTableView].origin];
    [self.backgroundView addSubview:self.topShadowImageView];
}

#pragma mark - Properties
- (CGRect)frameForTableView
{
    CGFloat originY = 50;
    CGFloat height = self.view.frame.size.height - originY;
    return CGRectMake(24.0, originY, 382.0, height);
}

- (ProfileStatusTableViewController *)statusTableViewController
{
    if (!_statusTableViewController) {
        _statusTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileStatusTableViewController"];
        _statusTableViewController.pageIndex = self.pageIndex;
        _statusTableViewController.view.frame = [self frameForTableView];
        _statusTableViewController.tableView.frame = [self frameForTableView];
        _statusTableViewController.user = self.currentUser;
        _statusTableViewController.type = statusTableViewControllerTypeMentionStatus;
        [self.backgroundView insertSubview:_statusTableViewController.view belowSubview:self.topShadowImageView];
    }
    return _statusTableViewController;
}

@end