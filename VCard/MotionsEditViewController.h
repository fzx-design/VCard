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

@protocol MotionsEditViewControllerDelegate;

@interface MotionsEditViewController : MultiInterfaceOrientationViewController

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UISlider *shadowAmountSlider;
@property (nonatomic, strong) IBOutlet UIButton *cropButton;
@property (nonatomic, strong) IBOutlet FilterImageView *filterImageView;
@property (nonatomic, weak) id<MotionsEditViewControllerDelegate> delegate;

- (IBAction)didChangeSlider:(UISlider *)sender;
- (IBAction)didClickCropButton:(UIButton *)sender;
- (IBAction)didClickRevertButton:(UIButton *)sender;
- (IBAction)didClickFinishEditButton:(UIButton *)sender;

- (id)initWithImage:(UIImage *)image;

@end

@protocol MotionsEditViewControllerDelegate <NSObject>

- (void)editViewControllerDidBecomeActiveWithCompletion:(void (^)(void))completion;
- (void)editViewControllerDidFinishEditImage:(UIImage *)image;
- (void)editViewControllerDidChooseToShoot;

@end
