//
//  StackViewPageController.h
//  VCard
//
//  Created by 海山 叶 on 12-5-26.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "BaseStackLayoutView.h"

@interface StackViewPageController : CoreDataViewController {
    NSInteger _pageIndex;
    BaseStackLayoutView *_backgroundView;
    
}

@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, strong) IBOutlet BaseStackLayoutView *backgroundView;

- (void)initialLoad;

@end
