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
    if (self.shouldShowFirst) {
        [self didClickCheckStatusButton:nil];
        [self.statusTableViewController refresh];
    } else {
        [self didClickCheckCommentButton:nil];
        [self.commentTableViewController refresh];
    }
    [self.commentTableViewController initialLoad];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.topShadowImageView resetOrigin:[self frameForTableView].origin];
    [self.backgroundView addSubview:self.topShadowImageView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.checkCommentButton.selected) {
        [_commentTableViewController viewWillDisappear:NO];
    } else {
        [_statusTableViewController viewWillDisappear:NO];
    }
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
    self.commentTableViewController.tableView.scrollsToTop = NO;
}

- (void)showWithPurpose
{
    if (self.shouldShowFirst) {
        [self didClickCheckStatusButton:nil];
        [self.statusTableViewController refresh];
    } else {
        [self didClickCheckCommentButton:nil];
        [self.commentTableViewController refresh];
    }
}

- (void)clearPage
{
    [_statusTableViewController.view removeFromSuperview];
    [_commentTableViewController.view removeFromSuperview];
    _statusTableViewController = nil;
    _commentTableViewController = nil;
}

- (IBAction)didClickCheckCommentButton:(id)sender
{
    self.checkCommentButton.selected = YES;
    self.checkStatusButton.selected = NO;
    
    self.checkStatusButton.userInteractionEnabled = YES;
    self.checkCommentButton.userInteractionEnabled = NO;
    
    [self.backgroundView insertSubview:self.commentTableViewController.view belowSubview:self.topShadowImageView];
    self.commentTableViewController.tableView.scrollsToTop = YES;
    if (_statusTableViewController) {
        [self.statusTableViewController.view removeFromSuperview];
        self.statusTableViewController.tableView.scrollsToTop = NO;
    }
}

- (IBAction)didClickCheckStatusButton:(id)sender
{
    self.checkStatusButton.selected = YES;
    self.checkCommentButton.selected = NO;
    
    self.checkStatusButton.userInteractionEnabled = NO;
    self.checkCommentButton.userInteractionEnabled = YES;
    
    [self.backgroundView insertSubview:self.statusTableViewController.view belowSubview:self.topShadowImageView];
    self.statusTableViewController.tableView.scrollsToTop = YES;
    if (_commentTableViewController) {
        [self.commentTableViewController.view removeFromSuperview];
        self.commentTableViewController.tableView.scrollsToTop = NO;
    }
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
    }
    return _statusTableViewController;
}

- (SelfCommentTableViewController *)commentTableViewController
{
    if (!_commentTableViewController) {
        _commentTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SelfCommentTableViewController"];
        _commentTableViewController.pageIndex = self.pageIndex;
        _commentTableViewController.view.frame = [self frameForTableView];
        _commentTableViewController.tableView.frame = [self frameForTableView];
        _commentTableViewController.dataSource = CommentsTableViewDataSourceCommentsMentioningMe;
    }
    return _commentTableViewController;
}

@end
