//
//  MotionsEditViewController.h
//  VCard
//
//  Created by 王 紫川 on 12-6-25.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiInterfaceOrientationViewController.h"
#import "FilterImageView.h"
#import "CropImageViewController.h"
#import "MotionsFilterTableViewController.h"

@protocol MotionsEditViewControllerDelegate;

@interface MotionsEditViewController : MultiInterfaceOrientationViewController <CropImageViewControllerDelegate, UIActionSheetDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MotionsFilterTableViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UISlider *shadowAmountSlider;
@property (nonatomic, weak) IBOutlet UIButton *cropButton;
@property (nonatomic, weak) IBOutlet UIButton *changePictureButton;
@property (nonatomic, weak) IBOutlet UIButton *revertButton;
@property (nonatomic, weak) IBOutlet UIButton *finishEditButton;
@property (nonatomic, weak) IBOutlet UIView *bgView;
@property (nonatomic, weak) IBOutlet UIView *functionView;
@property (nonatomic, weak) IBOutlet UIView *capturedImageEditBar;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UIView *editAccessoryView;
@property (nonatomic, weak) NSObject<MotionsEditViewControllerDelegate> *delegate;

@property (nonatomic, weak) IBOutlet FilterImageView *filterImageViewA;
@property (nonatomic, weak) IBOutlet FilterImageView *filterImageViewB;

@property (nonatomic, assign) BOOL isOriginalImageFromLibrary;

- (IBAction)didChangeSlider:(UISlider *)sender;
- (IBAction)didClickCropButton:(UIButton *)sender;
- (IBAction)didClickRevertButton:(UIButton *)sender;
- (IBAction)didClickFinishEditButton:(UIButton *)sender;
- (IBAction)didClickChangePictureButton:(UIButton *)sender;

- (id)initWithImage:(UIImage *)image useForAvatar:(BOOL)useForAvatar;
- (void)hideEditAccessoriesAnimationWithCompletion:(void (^)(void))completion;
- (void)showEditAccessoriesAnimationWithCompletion:(void (^)(void))completion;
    
@end

@protocol MotionsEditViewControllerDelegate <NSObject>

- (void)editViewControllerDidBecomeActiveWithCompletion:(void (^)(void))completion;
- (void)editViewControllerDidFinishEditImage:(UIImage *)image;
- (void)editViewControllerDidChooseToShoot;

@end
