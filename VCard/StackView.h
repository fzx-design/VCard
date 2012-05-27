//
//  StackView.h
//  VCard
//
//  Created by 海山 叶 on 12-5-26.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StackViewDelegate <NSObject>

@required
- (int)pageNumber;
- (UIView *)viewForPageIndex:(int)index;

@end

@interface StackView : UIView <UIScrollViewDelegate> {
    UIScrollView *_scrollView;
    
    __unsafe_unretained id<StackViewDelegate> _delegate;
}

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, assign) id<StackViewDelegate> delegate;

- (void)addNewPage:(UIView *)newPage replacingView:(BOOL)replacing;
- (void)removeLastView:(UIView *)lastView;

@end
