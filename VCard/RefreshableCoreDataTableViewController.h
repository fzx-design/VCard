//
//  RefreshableCoreDataTableViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-5-29.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "PullToRefreshView.h"
#import "LoadMoreView.h"
#import "BaseLayoutView.h"
#import "EmptyIndicatorViewController.h"

@class User;

@protocol CommentTableViewCellDelegate <NSObject>

- (void)commentTableViewCellDidComment;

@end

@interface RefreshableCoreDataTableViewController : CoreDataTableViewController <PullToRefreshViewDelegate, LoadMoreViewDelegate, UIScrollViewDelegate, UITableViewDelegate, CommentTableViewCellDelegate, EmptyIndicatorViewControllerDelegate> {
    
    PullToRefreshView *_pullView;
    LoadMoreView *_loadMoreView;
    
    User *_user;
    NSString *_identifier;
}

@property (nonatomic, unsafe_unretained) BOOL refreshing;
@property (nonatomic, unsafe_unretained) BOOL hasMoreViews;
@property (nonatomic, unsafe_unretained) int pageIndex;
@property (nonatomic, unsafe_unretained) BOOL firstLoad;
@property (nonatomic, unsafe_unretained) BOOL isBeingDisplayed;
@property (nonatomic, unsafe_unretained) BOOL isEmptyIndicatorForbidden;
@property (nonatomic, strong) EmptyIndicatorViewController *emptyIndicatorViewController;
@property (nonatomic, strong) User *user;

- (void)refresh;
- (void)refreshEnded;
- (void)loadMore;
- (void)adjustBackgroundView;
- (void)adjustFont;
- (void)refreshAfterPostingComment;
- (void)refreshAfterDeletingComment:(NSNotification *)notification;
- (void)refreshAfterDeletingStatuses:(NSNotification *)notification;
- (void)finishedLoading;

@end
