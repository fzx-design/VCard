//
//  CropImageViewController.h
//  VCard
//
//  Created by 紫川 王 on 12-4-19.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiInterfaceOrientationViewController.h"
#import "CropImageView.h"

@protocol CropImageViewControllerDelegate;

@interface CropImageViewController : MultiInterfaceOrientationViewController

@property (nonatomic, weak) id<CropImageViewControllerDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIImageView *cropImageBgView;
@property (nonatomic, weak) IBOutlet CropImageView *cropImageView;
@property (nonatomic, weak) IBOutlet UIView *editBarView;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

- (id)initWithImage:(UIImage *)image filteredImage:(UIImage *)filteredImage useForAvatar:(BOOL)useForAvatar;
- (void)zoomInFromCenter:(CGPoint)point withScaleFactor:(CGFloat)factor completion:(void (^)(void))completion;
- (void)zoomOutToCenter:(CGPoint)point withScaleFactor:(CGFloat)factor completion:(void (^)(void))completion;

- (IBAction)didClickFinishCropButton:(UIButton *)sender;
- (IBAction)didClickCancelButton:(UIButton *)sender;

@end

@protocol CropImageViewControllerDelegate <NSObject>

- (void)cropImageViewControllerDidFinishCrop:(UIImage *)image;
- (void)cropImageViewControllerDidCancelCrop;

@end
