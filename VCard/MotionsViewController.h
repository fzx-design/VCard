//
//  MotionsViewController.h
//  VCard
//
//  Created by 紫川 王 on 12-4-11.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MotionsCapturePreviewView.h"
#import "CropImageViewController.h"
#import "FilterImageView.h"

@protocol MotionsViewControllerDelegate;

@interface MotionsViewController : UIViewController <MotionsCapturePreviewViewDelegate, CropImageViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate>

@property (nonatomic, weak) id<MotionsViewControllerDelegate> delegate;

@property (nonatomic, strong) IBOutlet UIView *cameraPreviewBgView;
@property (nonatomic, strong) IBOutlet MotionsCapturePreviewView *cameraPreviewView;
@property (nonatomic, strong) IBOutlet UIImageView *capturedImageView;
@property (nonatomic, strong) IBOutlet UIImageView *cameraCoverImageView;
@property (nonatomic, strong) IBOutlet UIView *capturedImageEditView;
@property (nonatomic, strong) IBOutlet FilterImageView *filterImageView;

@property (nonatomic, strong) IBOutlet UIButton *cameraStatusLEDButton;

@property (nonatomic, strong) IBOutlet UIView *shotView;
@property (nonatomic, strong) IBOutlet UIView *editView;

@property (nonatomic, strong) IBOutlet UISlider *solarSlider;
@property (nonatomic, strong) IBOutlet UISlider *contrastSlider;
@property (nonatomic, strong) IBOutlet UIButton *optimizeButton;
@property (nonatomic, strong) IBOutlet UIButton *cropButton;
@property (nonatomic, strong) IBOutlet UIButton *finishCropButton;
@property (nonatomic, strong) IBOutlet UIImageView *effectShelfCoverImageView;

- (IBAction)didClickShotButton:(UIButton *)sender;
- (IBAction)didClickCancelButton:(UIButton *)sender;
- (IBAction)didChangeSlider:(UISlider *)sender;
- (IBAction)didClickBackToShotButton:(UIButton *)sender;
- (IBAction)didClickChangeCameraButton:(UIButton *)sender;
- (IBAction)didClickCropButton:(UIButton *)sender;
- (IBAction)didClickRevertButton:(UIButton *)sender;
- (IBAction)didClickPickImageButton:(UIButton *)sender;
- (IBAction)didClickFinishEditButton:(UIButton *)sender;

@end

@protocol MotionsViewControllerDelegate <NSObject>

@required
- (void)motionViewControllerDidFinish:(UIImage *)image;
- (void)motionViewControllerDidCancel;

@end
