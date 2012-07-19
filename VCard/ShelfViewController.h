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

@property (nonatomic, weak) IBOutlet UIScrollView     *scrollView;
@property (nonatomic, weak) IBOutlet UIImageView      *shelfBorderImageView;
@property (nonatomic, weak) IBOutlet UIButton         *switchToPicButton;
@property (nonatomic, weak) IBOutlet UIButton         *switchToTextButton;
@property (nonatomic, weak) IBOutlet UIButton         *detailSettingButton;
@property (nonatomic, weak) IBOutlet UISlider         *brightnessSlider;
@property (nonatomic, weak) IBOutlet UISlider         *fontSizeSlider;
@property (nonatomic, weak) IBOutlet ShelfPageControl *pageControl;
@property (nonatomic, strong) NSMutableArray          *drawerViewArray;
@property (nonatomic, weak) IBOutlet UIView           *coverView;

- (IBAction)didChangeValueOfSlider:(UISlider *)sender;
- (IBAction)didEndDraggingSlider:(UISlider *)sender;
- (IBAction)didClickDetialSettingButton:(UIButton *)sender;
- (IBAction)didClickSwitchModeButton:(UIButton *)sender;
- (IBAction)didChangePageControlValue:(UIPageControl *)sender;
- (void)loadImages;
- (void)exitEditMode;

@end
