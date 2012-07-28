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

@class User;

@protocol CommentTableViewCellDelegate <NSObject>

- (void)commentTableViewCellDidComment;

@end

@interface RefreshableCoreDataTableViewController : CoreDataTableViewController <PullToRefreshViewDelegate, LoadMoreViewDelegate, UIScrollViewDelegate, UITableViewDelegate, CommentTableViewCellDelegate> {
    
    PullToRefreshView *_pullView;
    LoadMoreView *_loadMoreView;
    
    User *_user;
    NSString *_identifier;
}

@property (nonatomic, unsafe_unretained) BOOL refreshing;
@property (nonatomic, unsafe_unretained) BOOL hasMoreViews;
@property (nonatomic, assign) int pageIndex;
@property (nonatomic, assign) BOOL firstLoad;
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
