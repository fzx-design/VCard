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
#import "UnreadCountButton.h"
#import "UnreadIndicatorButton.h"
#import "UnreadIndicatorView.h"

typedef enum {
    CastviewDataSourceNone,
    CastviewDataSourceFavourite,
    CastviewDataSourceGroup,
    CastviewDataSourceTopic,
} CastviewDataSource;

@protocol CastViewControllerDelegate <NSObject>

- (void)didDragCastViewWithOffset:(CGFloat)offset;
- (void)didSwipeCastView;
- (void)didEndDraggingCastViewWithOffset:(CGFloat)offset;

@end

@interface CastViewController : CoreDataViewController <WaterflowViewDelegate, WaterflowViewDatasource, PullToRefreshViewDelegate, LoadMoreViewDelegate, StackViewControllerDelegate, UIScrollViewDelegate, PostViewControllerDelegate> {
    
    PullToRefreshView *_pullView;
    LoadMoreView *_loadMoreView;
}

@property (nonatomic, weak) IBOutlet BaseNavigationView *navigationView;
@property (nonatomic, weak) IBOutlet WaterflowView *waterflowView;
@property (nonatomic, weak) IBOutlet RefreshIndicatorView *refreshIndicatorView;
@property (nonatomic, weak) IBOutlet RefreshIndicatorView *postIndicatorView;
@property (nonatomic, weak) IBOutlet UIImageView *profileImageView;
@property (nonatomic, weak) IBOutlet UIButton *searchButton;
@property (nonatomic, weak) IBOutlet UIButton *groupButton;
@property (nonatomic, weak) IBOutlet UIButton *createStatusButton;
@property (nonatomic, weak) IBOutlet UIButton *refreshButton;
@property (nonatomic, weak) IBOutlet UIButton *showDirectMessageButton;
@property (nonatomic, weak) IBOutlet UIButton *showProfileButton;
@property (nonatomic, weak) IBOutlet UnreadCountButton *unreadCountButton;
@property (nonatomic, weak) IBOutlet UnreadIndicatorButton *unreadCommentIndicatorButton;
@property (nonatomic, weak) IBOutlet UnreadIndicatorButton *unreadFollowerIndicatorButton;
@property (nonatomic, weak) IBOutlet UnreadIndicatorButton *unreadMentionIndicatorButton;
@property (nonatomic, weak) IBOutlet UnreadIndicatorButton *unreadMentionCommentIndicatorButton;
@property (nonatomic, weak) IBOutlet UnreadIndicatorButton *unreadMessageIndicatorButton;
@property (nonatomic, weak) IBOutlet UnreadIndicatorView *unreadIndicatorView;
@property (nonatomic, weak) IBOutlet UIView *waterflowViewAnimationCover;
@property (nonatomic, weak) id<CastViewControllerDelegate> delegate;
@property (nonatomic, strong) StackViewController *stackViewController;

- (void)initialLoad;
- (void)refresh;
- (IBAction)showProfileButtonClicked:(id)sender;
- (IBAction)refreshButtonClicked:(id)sender;
- (IBAction)didClickGroupButton:(id)sender;
- (IBAction)didClickCreateStatusButton:(UIButton *)sender;
- (IBAction)didClickSearchButton:(id)sender;
- (IBAction)didClickShowDirectMessageButton:(UIButton *)sender;
- (IBAction)didClickUnreadCommentButton:(UnreadIndicatorButton *)sender;
- (IBAction)didClickUnreadFollowerButton:(UnreadIndicatorButton *)sender;
- (IBAction)didClickUnreadMentionButton:(UnreadIndicatorButton *)sender;

@end
