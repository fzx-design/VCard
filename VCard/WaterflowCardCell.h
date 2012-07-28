//
//  WaterflowCardCell.h
//  VCard
//
//  Created by 海山 叶 on 12-5-22.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "WaterflowCell.h"
#import "CardViewController.h"

@interface WaterflowCardCell : WaterflowCell

@property (nonatomic, strong) CardViewController *cardViewController;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier currentUser:(User*)currentUser_;
- (void)loadImageAfterScrollingStop;
- (void)prepareForReuse;
- (void)setCellHeight:(CGFloat)height;

@end
