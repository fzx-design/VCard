//
//  ShelfViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-7-2.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataViewController.h"
#import "ShelfScrollView.h"
#import "ShelfBackgroundView.h"

@interface ShelfViewController : CoreDataViewController <UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView     *scrollView;
@property (nonatomic, strong) IBOutlet UIButton         *switchToPicButton;
@property (nonatomic, strong) IBOutlet UIButton         *switchToTextButton;
@property (nonatomic, strong) IBOutlet UIButton         *detailSettingButton;
@property (nonatomic, strong) IBOutlet UISlider         *brightnessSlider;
@property (nonatomic, strong) IBOutlet UISlider         *fontSizeSlider;
@property (nonatomic, strong) IBOutlet UIPageControl    *pageControl;

- (IBAction)didChangeValueOfSlider:(UISlider *)sender;
- (IBAction)didEndDraggingSlider:(UISlider *)sender;
- (IBAction)didClickDetialSettingButton:(UIButton *)sender;
- (IBAction)didClickSwitchModeButton:(UIButton *)sender;

@end
