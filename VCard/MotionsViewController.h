//
//  MotionsViewController.h
//  VCard
//
//  Created by 紫川 王 on 12-4-11.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MotionsShootViewController.h"
#import "MotionsEditViewController.h"
#import "MultiInterfaceOrientationViewController.h"

@protocol MotionsViewControllerDelegate;

@interface MotionsViewController : MultiInterfaceOrientationViewController <MotionsShootViewControllerDelegate, MotionsEditViewControllerDelegate>

@property (nonatomic, strong) MotionsShootViewController *shootViewController;
@property (nonatomic, strong) MotionsEditViewController *editViewController;
@property (nonatomic, weak) id<MotionsViewControllerDelegate> delegate;

@property (nonatomic, strong) IBOutlet UIImageView  *logoImageView;
@property (nonatomic, strong) IBOutlet UIImageView  *bgImageView;
@property (nonatomic, strong) IBOutlet UIView       *bgView;
@property (nonatomic, strong) IBOutlet UIButton     *cancelButton;
@property (nonatomic, strong) IBOutlet UIImageView  *leftCameraCoverImageView;
@property (nonatomic, strong) IBOutlet UIImageView  *rightCameraCoverImageView;
@property (nonatomic, strong) IBOutlet UIView       *captureBgView;

- (id)initWithImage:(UIImage *)image;

- (IBAction)didClickCancelButton:(UIButton *)sender;

@end

@protocol MotionsViewControllerDelegate <NSObject>

@required
- (void)motionViewControllerDidFinish:(UIImage *)image;
- (void)motionViewControllerDidCancel;

@end
