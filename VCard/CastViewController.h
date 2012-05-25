//
//  CastViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-4-18.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "PullToRefreshView.h"
#import "RefreshIndicatorView.h"
#import "WaterflowView.h"

@interface CastViewController : CoreDataTableViewController <WaterflowViewDelegate, WaterflowViewDatasource, PullToRefreshViewDelegate, UIScrollViewDelegate> {
    
    WaterflowView *_waterflowView;
    PullToRefreshView *_pullView;
    RefreshIndicatorView *_refreshIndicatorView;
    
    UIImageView *_profileImageView;
    UIButton *_searchButton;
    UIButton *_groupButton;
    UIButton *_createStatusButton;
    UIButton *_refreshButton;
    
}

@property(nonatomic, strong) IBOutlet WaterflowView *waterflowView;
@property(nonatomic, strong) IBOutlet RefreshIndicatorView *refreshIndicatorView;
@property (nonatomic, strong) IBOutlet UIImageView *profileImageView;
@property (nonatomic, strong) IBOutlet UIButton *searchButton;
@property (nonatomic, strong) IBOutlet UIButton *groupButton;
@property (nonatomic, strong) IBOutlet UIButton *createStatusButton;
@property (nonatomic, strong) IBOutlet UIButton *refreshButton;

- (IBAction)refreshButtonPressed:(id)sender;

@end
