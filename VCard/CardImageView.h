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

typedef enum {
    CastViewImageViewModeNormal,
    CastViewImageViewModePinchingOut,
    CastViewImageViewModePinchingIn,
    CastViewImageViewModeDetailedNormal,
    CastViewImageViewModeDetailedZooming,
} CastViewImageViewMode;

@interface CardImageView : UIView {
    CardImageViewShadowView *_shadowView;
    UIImageView *_imageView;
    UIImageView *_gifIcon;
    UIImage *_staticGIFImage;
    
    CGFloat _initialRotation;
    CGPoint _initialPosition;
    CGRect _initialFrame;
    CGSize _initialSize;
    CGFloat _initialScale;
    CGFloat _deltaWidth;
    CGFloat _deltaHeight;
    BOOL _isGIF;
}

@property (nonatomic, strong) UIImageView           *coverView;
@property (nonatomic, strong) UIImageView           *imageView;
@property (nonatomic, strong) UIImageView           *detailedImageView;
@property (nonatomic, strong) UIImageView           *gifIcon;
@property (nonatomic, readonly) UIImage             *image;
@property (nonatomic, assign) CGFloat               targetVerticalScale;
@property (nonatomic, assign) CGFloat               targetHorizontalScale;
@property (nonatomic, assign) CGFloat               currentScale;
@property (nonatomic, assign) BOOL                  loadingCompleted;
@property (nonatomic, assign) CastViewImageViewMode imageViewMode;

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
- (void)resetCurrentScale;
- (CGFloat)scaleOffset;
- (CGSize)targetSize;

@end
