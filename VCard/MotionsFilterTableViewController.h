//
//  MotionsFilterTableViewController.h
//  VCard
//
//  Created by 王 紫川 on 12-6-30.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiInterfaceOrientationViewController.h"
#import "MotionsFilterReader.h"

@protocol MotionsFilterTableViewControllerDelegate;

@interface MotionsFilterTableViewController : MultiInterfaceOrientationViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, weak) id<MotionsFilterTableViewControllerDelegate> delegate;

- (id)initWithImage:(UIImage *)image;
- (void)refreshWithImage:(UIImage *)image;

@end

@protocol MotionsFilterTableViewControllerDelegate <NSObject>

- (void)filterTableViewController:(MotionsFilterTableViewController *)vc didSelectFilter:(MotionsFilterInfo *)filter;

@end
