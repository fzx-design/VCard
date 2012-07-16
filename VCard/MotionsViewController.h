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

@property (nonatomic, weak) IBOutlet UIImageView  *logoImageView;
@property (nonatomic, weak) IBOutlet UIImageView  *bgImageView;
@property (nonatomic, weak) IBOutlet UIView       *bgView;
@property (nonatomic, weak) IBOutlet UIButton     *cancelButton;
@property (nonatomic, weak) IBOutlet UIImageView  *leftCameraCoverImageView;
@property (nonatomic, weak) IBOutlet UIImageView  *rightCameraCoverImageView;
@property (nonatomic, weak) IBOutlet UIView       *captureBgView;

- (id)initWithImage:(UIImage *)image useForAvatar:(BOOL)useForAvatar;
- (void)show;

- (IBAction)didClickCancelButton:(UIButton *)sender;

@end

@protocol MotionsViewControllerDelegate <NSObject>

@required
- (void)motionViewControllerDidFinish:(UIImage *)image;
- (void)motionViewControllerDidCancel;

@end
