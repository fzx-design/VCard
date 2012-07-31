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
#import "UserAccountManager.h"

typedef enum {
    StackViewPageTypeUser,
    StackViewPageTypeStatusComment,
    StackViewPageTypeStatusRepost,
    StackViewPageTypeSearch,
    StackViewPageTypeUserComment,
    StackViewPageTypeUserMention,
    StackViewPageTypeTopic,
    StackViewPageTypeDMList,
    StackViewPageTypeDMConversation,
} StackViewPageType;

@class StackViewPageController;

@protocol StackViewPageControllerDelegate <NSObject>

@required
- (void)stackViewPage:(StackViewPageController *)vc shouldBecomeActivePageAnimated:(BOOL)animated;

@end

@interface StackViewPageController : CoreDataViewController {
    NSInteger _pageIndex;
    BOOL _active;
}


@property (nonatomic, strong) UIImageView *topShadowImageView;
@property (nonatomic, weak) IBOutlet BaseStackLayoutView *backgroundView;

@property (nonatomic, copy) NSString *pageDescription;
@property (nonatomic, unsafe_unretained) NSInteger pageIndex;
@property (nonatomic, unsafe_unretained) StackViewPageType pageType;
@property (nonatomic, unsafe_unretained) BOOL loadWithPurpose;
@property (nonatomic, unsafe_unretained) BOOL shouldShowFirst;
@property (nonatomic, unsafe_unretained) BOOL isActive;
@property (nonatomic, weak)   id<StackViewPageControllerDelegate> delegate;

- (void)initialLoad;
- (void)stackScrolling:(CGFloat)speed;
- (void)stackScrollingStartFromLeft:(BOOL)toLeft;
- (void)stackScrollingEnd;
- (void)stackDidScroll;
- (void)enableScrollToTop;
- (void)disableScrollToTop;
- (void)pagePopedFromStack;
- (void)refresh;
- (void)showWithPurpose;
- (void)clearPage;

@end
