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
- (void)stackBecomedEmpty;
- (void)stackViewDidScroll;
- (void)stackViewDidEndScrolling;
- (void)stackViewWillScroll;
- (void)stackViewWillBeginDecelerating:(CGFloat)speed;
//- (void)stack

@end

@interface StackView : UIView <UIScrollViewDelegate> {
    UIScrollView *_scrollView;
    UIButton *_returnButton;
    __unsafe_unretained id<StackViewDelegate> _delegate;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIButton *returnButton;
@property (nonatomic, assign) id<StackViewDelegate> delegate;

- (void)addNewPage:(UIView *)newPage
     replacingView:(BOOL)replacing
        completion:(void (^)())completion;
- (void)removeLastView:(UIView *)lastView;
- (void)sendShowBGNotification;
- (void)scrollToTargetView:(UIView *)targetView;
- (int)currentPage;

@end
