//
//  LoadMoreView.h
//  VCard
//
//  Created by 海山 叶 on 12-5-30.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Resize.h"

typedef enum {
	LoadMoreViewStateHidden,
	LoadMoreViewStateLoading,
} LoadMoreViewState;

@class LoadMoreView;

@protocol LoadMoreViewDelegate <NSObject>
@optional
- (void)loadMoreViewShouldLoadMoreView:(LoadMoreView *)view;
@end

@interface LoadMoreView : UIView {
    LoadMoreViewState _state;
    UIActivityIndicatorView *_activityView;
}

- (void)setState:(LoadMoreViewState)state_;
- (void)finishedLoading:(BOOL)hasMoreViews;
- (void)startLoadingAnimation;
- (void)stopLoadingAnimation;
- (void)resetPosition;

- (id)initWithScrollView:(UIScrollView *)scrollView;

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) id<LoadMoreViewDelegate> delegate;
@property (nonatomic, assign) BOOL shouldAutoRotate;

@end
