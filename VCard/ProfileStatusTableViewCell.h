//
//  ProfileStatusTableViewCell.h
//  VCard
//
//  Created by 海山 叶 on 12-5-31.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardViewController.h"

@interface ProfileStatusTableViewCell : UITableViewCell {
    CardViewController *_cardViewController;
}

@property (nonatomic, strong) CardViewController *cardViewController;

- (void)setCellHeight:(CGFloat)height;
- (void)loadImageAfterScrollingStop;

@end
