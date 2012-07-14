//
//  SettingBrightnessCell.m
//  VCard
//
//  Created by 王 紫川 on 12-7-14.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "SettingBrightnessCell.h"

@implementation SettingBrightnessCell

@synthesize slider = _slider;

- (void)awakeFromNib {
    self.slider.value = [UIScreen mainScreen].brightness;
}

- (IBAction)didChangeSlider:(UISlider *)sender {
    [[UIScreen mainScreen] setBrightness:sender.value];
}

@end
