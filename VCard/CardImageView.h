//
//  CardImageView.h
//  VCard
//
//  Created by 海山 叶 on 12-4-14.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardImageViewShadowView.h"

#define StatusImageWidth 370

@interface CardImageView : UIView {
    CardImageViewShadowView *_shadowView;
    UIImageView *_imageView;
    UIImageView *_gifIcon;
    
    CGFloat _initialRotation;
    CGPoint _initialPosition;
    CGRect _initialFrame;
    CGSize _initialSize;
    CGFloat _deltaWidth;
    CGFloat _deltaHeight;
}

@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *detailedImageView;
@property (nonatomic, strong) UIImageView *gifIcon;
@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, assign) CGFloat targetScale;

- (void)resetHeight:(CGFloat)height;

- (void)loadImageFromURL:(NSString *)urlString 
              completion:(void (^)())completion;


- (void)loadDetailedImageFromURL:(NSString *)urlString
                      completion:(void (^)())completion;
- (void)clearCurrentImage;
- (void)reset;
- (void)playReturnAnimation;
- (void)returnToInitialPosition;
- (void)pinchResizeToScale:(CGFloat)scale;
- (CGSize)targetSize;

@end
