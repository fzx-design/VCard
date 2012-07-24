//
//  SelfCommentViewController.m
//  VCard
//
//  Created by Gabriel Yeah on 12-6-24.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "SelfCommentViewController.h"

@interface SelfCommentViewController ()

@end

@implementation SelfCommentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Over Load Method

- (void)initialLoad
{
    [self didClickSwitchToMeButton:nil];
    [self.commentToMeTableViewController initialLoad];
    [self.commentByMeTableViewController initialLoad];
}

- (void)refresh
{
    if (self.toMeButton.selected) {
        [self.commentToMeTableViewController refresh];
    } else if(self.byMeButton.selected) {
        [self.commentByMeTableViewController refresh];
    }
}

- (void)pagePopedFromStack
{
    
}

- (void)enableScrollToTop
{
    [super enableScrollToTop];
    self.commentToMeTableViewController.tableView.scrollsToTop = YES;
}

- (void)disableScrollToTop
{
    [super disableScrollToTop];
    self.commentToMeTableViewController.tableView.scrollsToTop = NO;
    self.commentByMeTableViewController.tableView.scrollsToTop = NO;
}

- (void)showWithPurpose
{
    [self didClickSwitchToMeButton:nil];
    [self.commentToMeTableViewController refresh];
}

- (void)clearPage
{
    [_commentToMeTableViewController.view removeFromSuperview];
    [_commentByMeTableViewController.view removeFromSuperview];
    _commentToMeTableViewController = nil;
    _commentByMeTableViewController = nil;
}

#pragma mark - Setup

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.topShadowImageView resetOrigin:[self frameForTableView].origin];
    [self.backgroundView addSubview:self.topShadowImageView];
    self.toMeButton.selected = YES;
}

#pragma mark - IBActions
- (IBAction)didClickSwitchToMeButton:(UIButton *)sender
{
    self.toMeButton.selected = YES;
    self.byMeButton.selected = NO;
    
    self.toMeButton.userInteractionEnabled = NO;
    self.byMeButton.userInteractionEnabled = YES;
    
    [self.backgroundView insertSubview:self.commentToMeTableViewController.view belowSubview:self.topShadowImageView];
    self.commentToMeTableViewController.tableView.scrollsToTop = YES;
    [self.commentToMeTableViewController adjustBackgroundView];
    if (_commentByMeTableViewController) {
        [self.commentByMeTableViewController.view removeFromSuperview];
        self.commentByMeTableViewController.tableView.scrollsToTop = NO;
    }
}

- (IBAction)didClickSwitchByMeButton:(UIButton *)sender
{
    self.toMeButton.selected = NO;
    self.byMeButton.selected = YES;
    
    self.toMeButton.userInteractionEnabled = YES;
    self.byMeButton.userInteractionEnabled = NO;
    
    [self.backgroundView insertSubview:self.commentByMeTableViewController.view belowSubview:self.topShadowImageView];
    self.commentByMeTableViewController.tableView.scrollsToTop = YES;
    [self.commentByMeTableViewController adjustBackgroundView];
    if (_commentToMeTableViewController) {
        [self.commentToMeTableViewController.view removeFromSuperview];
        self.commentToMeTableViewController.tableView.scrollsToTop = NO;
    }
}

- (CGRect)frameForTableView
{
    CGFloat originY = 50;
    CGFloat height = self.view.frame.size.height - originY;
    return CGRectMake(24.0, originY, 382.0, height);
}

- (SelfCommentTableViewController *)commentToMeTableViewController
{
    if (!_commentToMeTableViewController) {
        _commentToMeTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SelfCommentTableViewController"];
        _commentToMeTableViewController.pageIndex = self.pageIndex;
        _commentToMeTableViewController.view.frame = [self frameForTableView];
        _commentToMeTableViewController.tableView.frame = [self frameForTableView];
        _commentToMeTableViewController.dataSource = CommentsTableViewDataSourceCommentsToMe;
//        _commentByMeTableViewController.firstLoad = YES;
//        [self.backgroundView insertSubview:_commentToMeTableViewController.view belowSubview:self.topShadowImageView];
    }
    return _commentToMeTableViewController;
}

- (SelfCommentTableViewController *)commentByMeTableViewController
{
    if (!_commentByMeTableViewController) {
        _commentByMeTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SelfCommentTableViewController"];
        _commentByMeTableViewController.pageIndex = self.pageIndex;
        _commentByMeTableViewController.view.frame = [self frameForTableView];
        _commentByMeTableViewController.tableView.frame = [self frameForTableView];
        _commentByMeTableViewController.dataSource = CommentsTableViewDataSourceCommentsByMe;
//        _commentByMeTableViewController.firstLoad = YES;
//        [self.backgroundView insertSubview:_commentByMeTableViewController.view belowSubview:self.topShadowImageView];
    }
    return _commentByMeTableViewController;
}

@end
