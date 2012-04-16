//
//  BaseCardBackgroundView.h
//  VCard
//
//  Created by 海山 叶 on 12-4-14.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseCardBackgroundView : UIView {
    CGFloat _height;
    UIImageView *_cardTopView;
    UIImageView *_cardCenterView;
    UIImageView *_cardBottomView;
    
    UIView *_backgroundImageView;
}

@property (nonatomic, strong) UIImageView *cardTopView;
@property (nonatomic, strong) UIImageView *cardCenterView;
@property (nonatomic, strong) UIImageView *cardBottomView;

@end
