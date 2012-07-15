//
//  SearchUserResultViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-7-15.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "SearchUserResultViewController.h"

@interface SearchUserResultViewController ()

@end

@implementation SearchUserResultViewController

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
    _titleLabel.text = _searchKey;
    [self.topShadowImageView resetOrigin:[self frameForTableView].origin];
    [self.backgroundView insertSubview:self.topShadowImageView aboveSubview:self.userListViewController.view];
    [self.userListViewController refresh];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Properties
- (CGRect)frameForTableView
{
    CGFloat originY = 44;
    CGFloat height = self.view.frame.size.height - originY;
    return CGRectMake(24.0, originY, 382.0, height);
}

- (ProfileRelationTableViewController *)userListViewController
{
    if (!_userListViewController) {
        _userListViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileRelationTableViewController"];
        _userListViewController.pageIndex = self.pageIndex;
        _userListViewController.view.frame = [self frameForTableView];
        _userListViewController.tableView.frame = [self frameForTableView];
        _userListViewController.searchKey = _searchKey;
        _userListViewController.type = RelationshipViewTypeSearch;
        [self.backgroundView addSubview:_userListViewController.view];
    }
    return _userListViewController;
}

@end
