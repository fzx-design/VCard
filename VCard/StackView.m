//
//  StackView.m
//  VCard
//
//  Created by 海山 叶 on 12-5-26.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "StackView.h"
#import "UIView+Resize.h"

#define PageWidth 430.0
#define ScrollViewWidth 384.0


@interface StackView () {
    NSInteger _currentPageIndex;
    CGFloat _previousOffset;
    BOOL _covered;
    BOOL _shouldRecordDeceleratingFirst;
    BOOL _shouldRecordDeceleratingSecond;
}

@end

@implementation StackView

@synthesize returnButton = _returnButton;
@synthesize scrollView = _scrollView;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpScrollView];
        _covered = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUpScrollView];
        _covered = NO;
    }
    return self;
}

- (int)currentPage
{
    return self.scrollView.contentOffset.x / ScrollViewWidth - 1;
}

#pragma mark - Handle Changes To The Stack

- (void)setUpScrollView
{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.frame.size.width - ScrollViewWidth, 0.0, ScrollViewWidth, self.frame.size.height)];
    _scrollView.clipsToBounds = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delegate = self;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
    
    _returnButton = [[UIButton alloc] initWithFrame:CGRectMake(-256.0, 0.0, 640.0, 961.0)];
    _returnButton.autoresizingMask = UIViewAutoresizingNone;
    [_returnButton addTarget:self action:@selector(returnButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [_scrollView addSubview:_returnButton];
    
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
    [self addSubview:_scrollView];
}

- (void)scrollToTargetView:(UIView *)targetView
{
    [UIView animateWithDuration:0.3 animations:^{
        _scrollView.contentOffset = CGPointMake(targetView.frame.origin.x, 0.0);
    }];
}

- (void)addNewPage:(UIView *)newPage replacingView:(BOOL)replacing completion:(void (^)())completion
{
    int pageNumber = [_delegate pageNumber];
    int width = ScrollViewWidth * (pageNumber + 1);
    
    newPage.frame = [self frameForNewView:pageNumber];
    
    [_scrollView setContentSize:CGSizeMake(width, 705.0)];
    [_scrollView addSubview:newPage];
    
    if (replacing) {
        
        [self sendShowBGNotification];
        
        [newPage resetOriginX:newPage.frame.origin.x + ScrollViewWidth];
        [UIView animateWithDuration:0.3 animations:^{
            [newPage resetOriginX:newPage.frame.origin.x - ScrollViewWidth];
        } completion:^(BOOL finished) {
            [self scrollViewDidScroll:_scrollView];
        }];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        [_scrollView setContentOffset:CGPointMake(newPage.frame.origin.x, 0.0)];
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (CGRect)frameForNewView:(int)pageNumber
{
    return CGRectMake((pageNumber) * ScrollViewWidth, 0.0, 384.0, self.frame.size.height);
}

- (void)removeLastView:(UIView *)lastView
{
    [UIView animateWithDuration:0.3 animations:^{
        [lastView resetOriginX:lastView.frame.origin.x + ScrollViewWidth];
    } completion:^(BOOL finished) {
        [lastView removeFromSuperview];
    }];
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetX = scrollView.contentOffset.x;
    if (offsetX < ScrollViewWidth) {
        CGFloat backgroundAlpha = offsetX / ScrollViewWidth * 0.6;
        self.superview.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:backgroundAlpha];
    }
    
    CGFloat leftMargin = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? 256.0 : 0.0;
    
    if (scrollView.contentOffset.x >= 2 * ScrollViewWidth + leftMargin && 
        scrollView.contentOffset.x < scrollView.contentSize.width - ScrollViewWidth) {
        [self sendHideBGNotification];
    } else {
        [self sendShowBGNotification];
    }
    
    [_delegate stackViewDidScroll];
    
    if (_shouldRecordDeceleratingFirst) {
        _previousOffset = self.scrollView.contentOffset.x;
        _shouldRecordDeceleratingFirst = NO;
        _shouldRecordDeceleratingSecond = YES;
    } else if (_shouldRecordDeceleratingSecond){
        CGFloat offset = self.scrollView.contentOffset.x - _previousOffset;
        [_delegate stackViewWillBeginDecelerating:offset];
        _shouldRecordDeceleratingSecond = NO;
    }
}
     
- (void)sendShowBGNotification
{
    if (_covered) {
        _covered = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameStackViewDoNotCoverWholeScreen object:nil];
    }
}

- (void)sendHideBGNotification
{
    if (!_covered) {
        _covered = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameStackViewCoveredWholeScreen object:nil];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x == 0.0) {
        self.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.3 animations:^{
            [self resetOriginX:self.frame.origin.x + 200.0];
        } completion:^(BOOL finished) {
            //FIXME: Crashed
            [_delegate stackBecomedEmpty];
        }];
    }
    [_delegate stackViewDidEndScrolling];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_delegate stackViewWillScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    _shouldRecordDeceleratingFirst = decelerate;
    if (decelerate) {
        _previousOffset = scrollView.contentOffset.x;
    }
}

- (void)returnButtonClicked
{
    self.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.3 animations:^{
        _scrollView.contentOffset = CGPointZero;
    } completion:^(BOOL finished) {
        [_delegate stackBecomedEmpty];
    }];
}

#pragma mark - Handle Touch Event

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGPoint cp = [self convertPoint:point toView:_scrollView];
    if ([_scrollView pointInside:cp withEvent:event]) {
        return [_scrollView hitTest:cp withEvent:event];
    }
    
    CGPoint superPoint = [self convertPoint:point toView:self.superview];
    int touchedPageIndex = [self touchedPageIndex:superPoint];
    if (touchedPageIndex >= 0) {
        
        CGPoint subPoint = [self convertPoint:superPoint];
        UIView *pageView = [_delegate viewForPageIndex:touchedPageIndex];
        
        for(UIView *subview in pageView.subviews) {
            UIView *view = [subview hitTest:subPoint withEvent:event];
            if (view)
                return view;
        }
        return _scrollView;
        
    } else {
        return [_returnButton pointInside:superPoint withEvent:event] ? _returnButton : _scrollView;
    }
}

- (int)touchedPageIndex:(CGPoint)point
{
    CGFloat screenWidth = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? 1024.0 : 768.0;
    int currentPageIndex = _scrollView.contentOffset.x / ScrollViewWidth - 1;
    int touchedPageIndex;
    if (point.x > screenWidth - ScrollViewWidth) {
        touchedPageIndex = currentPageIndex;
    } else if (point.x > screenWidth - ScrollViewWidth * 2){
        touchedPageIndex = currentPageIndex - 1;
    } else {
        touchedPageIndex = currentPageIndex - 2;
    }
    return touchedPageIndex;
}

- (CGPoint)convertPoint:(CGPoint)point
{
    CGPoint result = point;
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        if (result.x > 256.0) {
            result.x -= 256.0;
        } else {
            result.x = -result.x;
        }
    }
    return result;
}

@end
