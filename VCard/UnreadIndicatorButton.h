//
//  UnreadIndicatorButton.h
//  VCard
//
//  Created by 海山 叶 on 12-6-29.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnreadIndicatorButton : UIButton {
    UIImageView *_highlightImageView;
}

@property (nonatomic, assign) NSInteger previousCount;

- (void)showIndicatingAnimation;
- (void)showIndicatorUpdatedAnimation;

@end
