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

typedef enum {
    StackViewPageTypeUser,
    StackViewPageTypeStatusComment,
    StackViewPageTypeStatusRepost,
    StackViewPageTypeSearch,
    StackViewPageTypeUserComment,
    StackViewPageTypeUserMention,
} StackViewPageType;

@interface StackViewPageController : CoreDataViewController {
    NSInteger _pageIndex;
    BOOL _active;
    BaseStackLayoutView *_backgroundView;
}

@property (nonatomic, assign) NSInteger pageIndex;

@property (nonatomic, strong) UIImageView *topShadowImageView;
@property (nonatomic, strong) IBOutlet BaseStackLayoutView *backgroundView;

@property (nonatomic, strong) NSString *pageDescription;
@property (nonatomic, assign) StackViewPageType pageType;

- (void)initialLoad;
- (void)stackScrolling;
- (void)stackScrollingStart;
- (void)stackScrollingEnd;
- (void)enableScrollToTop;
- (void)disableScrollToTop;
- (void)pagePopedFromStack;
- (void)refresh;

@end
