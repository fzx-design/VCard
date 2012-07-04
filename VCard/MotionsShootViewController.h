//
//  MotionsShootViewController.h
//  VCard
//
//  Created by 王 紫川 on 12-6-25.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MotionsCapturePreviewView.h"
#import "MultiInterfaceOrientationViewController.h"

@protocol MotionsShootViewControllerDelegate;

@interface MotionsShootViewController : MultiInterfaceOrientationViewController <MotionsCapturePreviewViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate>

@property (nonatomic, weak) id<MotionsShootViewControllerDelegate> delegate;

@property (nonatomic, strong) IBOutlet MotionsCapturePreviewView *cameraPreviewView;
@property (nonatomic, strong) IBOutlet UIButton *cameraStatusLEDButton;
@property (nonatomic, strong) IBOutlet UIButton *shootButton;
@property (nonatomic, strong) IBOutlet UIButton *pickImageButton;
@property (nonatomic, strong) IBOutlet UIView *shootAccessoryView;

- (IBAction)didClickShootButton:(UIButton *)sender;
- (IBAction)didClickChangeCameraButton:(UIButton *)sender;
- (IBAction)didClickPickImageButton:(UIButton *)sender;

- (void)startShoot;
- (void)hideShootAccessoriesAnimationWithCompletion:(void (^)(void))completion;
- (void)showShootAccessoriesAnimationWithCompletion:(void (^)(void))completion;

@end

@protocol MotionsShootViewControllerDelegate <NSObject>

- (void)shootViewController:(MotionsShootViewController *)vc didCaptureImage:(UIImage *)image;
- (void)shootViewControllerWillBecomeActiveWithCompletion:(void (^)(void))completion;
- (void)shootViewControllerWillBecomeInactiveWithCompletion:(void (^)(void))completion;

@end
