//
//  CardImageViewShadowView.h
//  VCard
//
//  Created by 海山 叶 on 12-4-16.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardImageViewShadowView : UIView {
    UIImageView *_topView;
    UIImageView *_centerView;
    UIImageView *_bottomView;
}

@property (nonatomic, strong) UIImageView *topView;
@property (nonatomic, strong) UIImageView *centerView;
@property (nonatomic, strong) UIImageView *bottomView;

@end
