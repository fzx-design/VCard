//
//  StackView.m
//  VCard
//
//  Created by 海山 叶 on 12-5-26.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "StackView.h"

#define PageWidth 430.0
#define ScrollViewWidth 408.0

@interface StackView () {
    NSInteger _currentPageIndex;
}

@end

@implementation StackView

@synthesize scrollView = _scrollView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpScrollView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUpScrollView];
    }
    return self;
}

- (void)setUpScrollView
{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.frame.size.width - ScrollViewWidth, 0.0, ScrollViewWidth, self.frame.size.height)];
    _scrollView.clipsToBounds = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delegate = self;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
    [self addSubview:_scrollView];
}

- (void)addNewPage:(UIView *)newPage
{
    newPage.frame = [self frameForNewView];
    
    _scrollView.contentSize = CGSizeMake(409, self.frame.size.height);
    [_scrollView addSubview:newPage];
}

- (CGRect)frameForNewView
{
    return CGRectMake(_currentPageIndex * PageWidth, 0.0, PageWidth, self.frame.size.height);
}


@end
