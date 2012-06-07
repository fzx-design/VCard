//
//  PostRootView.h
//  VCard
//
//  Created by 紫川 王 on 12-6-7.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    PostRootViewSubviewTagNone = 0,
    PostRootViewSubviewTagEmoticons,
} PostRootViewSubviewTag;

@protocol PostRootViewDelegate;
@interface PostRootView : UIView

@property (nonatomic, assign) NSInteger observingViewTag;
@property (nonatomic, weak) id<PostRootViewDelegate> delegate;

@end

@protocol PostRootViewDelegate <NSObject>

- (void)postRootView:(PostRootView *)view didObserveTouchOtherView:(UIView *)otherView;

@end