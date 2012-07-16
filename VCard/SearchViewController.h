//
//  SearchViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-7-4.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "StackViewPageController.h"
#import "SearchTableViewController.h"

@interface SearchViewController : StackViewPageController <UISearchBarDelegate, SearchTableViewControllerDelegate>

@property (nonatomic, strong) SearchTableViewController *searchTableViewController;
@property (nonatomic, weak) IBOutlet UIView           *segmentView;
@property (nonatomic, weak) IBOutlet UIImageView      *searchBarCoverView;
@property (nonatomic, weak) IBOutlet UIButton         *searchUserButton;
@property (nonatomic, weak) IBOutlet UIButton         *searchStatusButton;
@property (nonatomic, weak) IBOutlet UISearchBar      *searchBar;

- (IBAction)didClickSegmentButton:(UIButton *)sender;

@end
