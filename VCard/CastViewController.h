//
//  CastViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-4-18.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "BaseNavigationView.h"
#import "WaterflowView.h"
#import "PullToRefreshView.h"
#import "LoadMoreView.h"
#import "RefreshIndicatorView.h"
#import "StackViewController.h"
#import "PostViewController.h"

@interface CastViewController : CoreDataViewController <WaterflowViewDelegate, WaterflowViewDatasource, PullToRefreshViewDelegate, LoadMoreViewDelegate, StackViewControllerDelegate, UIScrollViewDelegate, PostViewControllerDelegate> {
    
    BaseNavigationView *_navigationView;
    PullToRefreshView *_pullView;
    LoadMoreView *_loadMoreView;
    WaterflowView *_waterflowView;
    RefreshIndicatorView *_refreshIndicatorView;
    
    StackViewController *_stackViewController;
    
    UIImageView *_profileImageView;
    UIButton *_searchButton;
    UIButton *_groupButton;
    UIButton *_createStatusButton;
    UIButton *_refreshButton;
    UIButton *_showProfileButton;
}

@property (nonatomic, strong) IBOutlet BaseNavigationView *navigationView;
@property (nonatomic, strong) IBOutlet WaterflowView *waterflowView;
@property (nonatomic, strong) IBOutlet RefreshIndicatorView *refreshIndicatorView;
@property (nonatomic, strong) IBOutlet UIImageView *profileImageView;
@property (nonatomic, strong) IBOutlet UIButton *searchButton;
@property (nonatomic, strong) IBOutlet UIButton *groupButton;
@property (nonatomic, strong) IBOutlet UIButton *createStatusButton;
@property (nonatomic, strong) IBOutlet UIButton *refreshButton;
@property (nonatomic, strong) IBOutlet UIButton *showProfileButton;

- (void)initialLoad;
- (IBAction)showProfileButtonClicked:(id)sender;
- (IBAction)refreshButtonClicked:(id)sender;
- (IBAction)groupButtonClicked:(id)sender;
- (IBAction)didClickCreateStatusButton:(UIButton *)sender;

@end
