//
//  MotionsShootViewController.h
//  VCard
//
//  Created by 王 紫川 on 12-6-25.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MotionsCapturePreviewView.h"

@protocol MotionsShootViewControllerDelegate;

@interface MotionsShootViewController : UIViewController <MotionsCapturePreviewViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate>

@property (nonatomic, weak) id<MotionsShootViewControllerDelegate> delegate;

@property (nonatomic, strong) IBOutlet MotionsCapturePreviewView *cameraPreviewView;
@property (nonatomic, strong) IBOutlet UIButton *cameraStatusLEDButton;
@property (nonatomic, strong) IBOutlet UIButton *shootButton;
@property (nonatomic, strong) IBOutlet UIButton *pickImageButton;

- (IBAction)didClickShootButton:(UIButton *)sender;
- (IBAction)didClickChangeCameraButton:(UIButton *)sender;
- (IBAction)didClickPickImageButton:(UIButton *)sender;

- (void)configureOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end

@protocol MotionsShootViewControllerDelegate <NSObject>

- (void)shootViewController:(MotionsShootViewController *)vc didCaptureImage:(UIImage *)image;
- (void)shootViewControllerWillBecomeActiveWithCompletion:(void (^)(void))completion;
- (void)shootViewControllerWillBecomeInactiveWithCompletion:(void (^)(void))completion;

@end
