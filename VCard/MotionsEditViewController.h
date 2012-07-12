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

@property (nonatomic, strong) IBOutlet UISlider *shadowAmountSlider;
@property (nonatomic, strong) IBOutlet UIButton *cropButton;
@property (nonatomic, strong) IBOutlet UIButton *changePictureButton;
@property (nonatomic, strong) IBOutlet UIButton *revertButton;
@property (nonatomic, strong) IBOutlet UIButton *finishEditButton;
@property (nonatomic, strong) IBOutlet FilterImageView *filterImageView;
@property (nonatomic, strong) IBOutlet UIView *bgView;
@property (nonatomic, strong) IBOutlet UIView *functionView;
@property (nonatomic, strong) IBOutlet UIImageView *capturedImageView;
@property (nonatomic, strong) IBOutlet UIView *capturedImageEditBar;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) IBOutlet UIView *editAccessoryView;
@property (nonatomic, weak) id<MotionsEditViewControllerDelegate> delegate;

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
