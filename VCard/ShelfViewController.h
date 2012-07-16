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
#import "ShelfPageControl.h"
#import "ShelfDrawerView.h"

@interface WBGroupInfo : NSObject

@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSString *groupPicURL;

@end

@interface ShelfViewController : CoreDataViewController <UIScrollViewDelegate, ShelfDrawerViewDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView     *scrollView;
@property (nonatomic, strong) IBOutlet UIImageView      *shelfBorderImageView;
@property (nonatomic, strong) IBOutlet UIButton         *switchToPicButton;
@property (nonatomic, strong) IBOutlet UIButton         *switchToTextButton;
@property (nonatomic, strong) IBOutlet UIButton         *detailSettingButton;
@property (nonatomic, strong) IBOutlet UISlider         *brightnessSlider;
@property (nonatomic, strong) IBOutlet UISlider         *fontSizeSlider;
@property (nonatomic, strong) IBOutlet ShelfPageControl *pageControl;
@property (nonatomic, strong) NSMutableArray            *drawerViewArray;
@property (nonatomic, strong) IBOutlet UIView           *coverView;

- (IBAction)didChangeValueOfSlider:(UISlider *)sender;
- (IBAction)didEndDraggingSlider:(UISlider *)sender;
- (IBAction)didClickDetialSettingButton:(UIButton *)sender;
- (IBAction)didClickSwitchModeButton:(UIButton *)sender;
- (IBAction)didChangePageControlValue:(UIPageControl *)sender;
- (void)loadImages;

@end
