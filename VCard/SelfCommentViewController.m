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
    [self.commentTableViewController refresh];
    self.pageType = StackViewPageTypeStatusComment;
    self.pageDescription = @"";
}

#pragma mark - Setup

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.topShadowImageView resetOrigin:[self frameForTableView].origin];
    [self.backgroundView addSubview:self.topShadowImageView];
}


#pragma mark - IBActions
- (IBAction)didClickSwitchToMeButton:(UIButton *)sender
{
    self.toMeButton.selected = YES;
    self.byMeButton.selected = NO;
    [self.commentTableViewController switchToToMe];
}

- (IBAction)didClickSwitchByMeButton:(UIButton *)sender
{
    self.toMeButton.selected = NO;
    self.byMeButton.selected = YES;
    [self.commentTableViewController switchToByMe];
}

- (CGRect)frameForTableView
{
    CGFloat originY = 50;
    CGFloat height = self.view.frame.size.height - originY;
    return CGRectMake(24.0, originY, 382.0, height);
}

- (SelfCommentTableViewController *)commentTableViewController
{
    if (!_commentTableViewController) {
        _commentTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SelfCommentTableViewController"];
        _commentTableViewController.pageIndex = self.pageIndex;
        _commentTableViewController.view.frame = [self frameForTableView];
        _commentTableViewController.tableView.frame = [self frameForTableView];
        [self.backgroundView insertSubview:_commentTableViewController.view belowSubview:self.topShadowImageView];        
    }
    return _commentTableViewController;
}

@end
