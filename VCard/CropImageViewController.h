//
//  CropImageViewController.h
//  VCard
//
//  Created by 紫川 王 on 12-4-19.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CropImageView.h"

@protocol CropImageViewControllerDelegate;

@interface CropImageViewController : UIViewController

@property (nonatomic, weak) id<CropImageViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UIImageView *cropImageBgView;
@property (nonatomic, strong) IBOutlet CropImageView *cropImageView;
@property (nonatomic, strong) IBOutlet UIView *editBarView;

- (id)initWithImage:(UIImage *)image filteredImage:(UIImage *)filteredImage;
- (void)zoomInFromCenter:(CGPoint)point withScaleFactor:(CGFloat)factor completion:(void (^)(void))completion;
- (void)zoomOutToCenter:(CGPoint)point withScaleFactor:(CGFloat)factor completion:(void (^)(void))completion;

- (IBAction)didClickFinishCropButton:(UIButton *)sender;
- (IBAction)didClickCancelButton:(UIButton *)sender;

@end

@protocol CropImageViewControllerDelegate <NSObject>

- (void)cropImageViewControllerDidFinishCrop:(UIImage *)image;
- (void)cropImageViewControllerDidCancelCrop;

@end
