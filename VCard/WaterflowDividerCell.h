//
//  WaterflowDividerCell.h
//  VCard
//
//  Created by 海山 叶 on 12-5-22.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "WaterflowCell.h"
#import "DividerViewController.h"

@interface WaterflowDividerCell : WaterflowCell {
    DividerViewController *_dividerViewController;
}

@property (nonatomic, strong) DividerViewController *dividerViewController;

- (void)resetLayoutAfterRotating;

@end
