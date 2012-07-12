//
//  CropImageView.h
//  VCard
//
//  Created by 紫川 王 on 12-4-18.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CropImageView : UIView

@property (nonatomic, readonly) CGRect cropImageRect;
@property (nonatomic, readonly) CGRect cropEditRect;
@property (nonatomic, assign) CGFloat rotationFactor;
@property (nonatomic, assign) CGFloat scaleFactor;
@property (nonatomic, weak) UIImageView *bgImageView;

- (void)setCropImageInitSize:(CGSize)size center:(CGPoint)center lockRatio:(BOOL)lockRatio;

@end
