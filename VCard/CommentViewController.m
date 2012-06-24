//
//  CommentViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-5-31.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "CommentViewController.h"
#import "PostViewController.h"
#import "UIApplication+Addition.h"
#import "User.h"

@implementation CommentViewController

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
    [self.commentTableViewController setUpHeaderView];
    self.pageType = StackViewPageTypeStatusComment;
    self.pageDescription = self.status.statusID;
}

#pragma mark - Setup

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.topShadowImageView resetOrigin:[self frameForTableView].origin];
    [self.backgroundView addSubview:self.topShadowImageView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.commentButton = nil;
}

#pragma mark - IBActions

-(IBAction)didClickChangeSourceButton:(UIButton *)sender
{
    [self.commentTableViewController changeSource];
    if (self.commentTableViewController.filterByAuthor) {
        [self.changeSourceButton setTitle:@"查看所有" forState:UIControlStateNormal];
        [self.changeSourceButton setTitle:@"查看所有" forState:UIControlStateHighlighted];
        self.titleLabel.text =  @"关注的人的评论";
    } else {
        [self.changeSourceButton setTitle:@"只查看关注" forState:UIControlStateNormal];
        [self.changeSourceButton setTitle:@"只查看关注" forState:UIControlStateHighlighted];
        self.titleLabel.text =  @"所有评论";
    }
}

- (IBAction)didClickCommentButton:(UIButton *)sender
{
    NSString *targetUserName = self.status.author.screenName;
    NSString *targetStatusID = self.status.statusID;
    CGRect frame = [self.view convertRect:sender.frame toView:[UIApplication sharedApplication].rootViewController.view];

    PostViewController *vc = [PostViewController getCommentWeiboViewControllerWithWeiboID:targetStatusID weiboOwnerName:targetUserName Delegate:self];
    [vc showViewFromRect:frame];
}

#pragma mark - Properties
- (CGRect)frameForTableView
{
    CGFloat originY = 50;
    CGFloat height = self.view.frame.size.height - originY;
    return CGRectMake(24.0, originY, 382.0, height);
}

- (ProfileCommentTableViewController *)commentTableViewController
{
    if (!_commentTableViewController) {
        _commentTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileCommentTableViewController"];
        _commentTableViewController.pageIndex = self.pageIndex;
        _commentTableViewController.view.frame = [self frameForTableView];
        _commentTableViewController.tableView.frame = [self frameForTableView];
        _commentTableViewController.status = self.status;
        [self.backgroundView insertSubview:_commentTableViewController.view belowSubview:self.topShadowImageView];
        
        
    }
    return _commentTableViewController;
}

#pragma mark - PostViewController Delegate

- (void)postViewController:(PostViewController *)vc willPostMessage:(NSString *)message {
    [vc dismissViewUpwards];
}

- (void)postViewController:(PostViewController *)vc didPostMessage:(NSString *)message {
    
}

- (void)postViewController:(PostViewController *)vc didFailPostMessage:(NSString *)message {
    
}

- (void)postViewController:(PostViewController *)vc willDropMessage:(NSString *)message {
    [vc dismissViewToRect:[self.view convertRect:self.commentButton.frame toView:[UIApplication sharedApplication].rootViewController.view]];
}

@end
