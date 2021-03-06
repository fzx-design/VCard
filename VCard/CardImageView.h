//
//  CardImageView.h
//  VCard
//
//  Created by 海山 叶 on 12-4-14.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardImageViewShadowView.h"

#define StatusImageWidth        370
#define kActionButtonTypeMedia  0
#define kActionButtonTypeVote   1

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
    
    CGFloat _initialRotation;
    CGPoint _initialPosition;
    CGRect _initialFrame;
    CGSize _initialSize;
    CGFloat _initialScale;
    BOOL _isGIF;
}

@property (nonatomic, strong) UIImageView           *coverView;
@property (nonatomic, strong) UIImageView           *imageView;
@property (nonatomic, strong) UIImageView           *gifIcon;
@property (nonatomic, readonly) UIImage             *image;
@property (nonatomic, assign) CGFloat               targetVerticalScale;
@property (nonatomic, assign) CGFloat               targetHorizontalScale;
@property (nonatomic, assign) CGFloat               currentScale;
@property (nonatomic, assign) BOOL                  loadingCompleted;
@property (nonatomic, assign) CastViewImageViewMode imageViewMode;

@property (nonatomic, strong) NSString              *url;
@property (nonatomic, strong) UIButton              *actionButton;

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
- (void)setUpPlayButtonWithURL:(NSString *)url type:(int)type;
- (void)didClickActionButton;

@end
