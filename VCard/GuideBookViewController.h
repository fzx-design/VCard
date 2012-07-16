//
//  GuideBookViewController.h
//  VCard
//
//  Created by 王 紫川 on 12-7-12.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShelfPageControl.h"

@interface GuideBookViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet ShelfPageControl *pageControl;
@property (nonatomic, weak) IBOutlet UIButton *finishButton;
@property (nonatomic, weak) IBOutlet UIImageView *iconImageView;
@property (nonatomic, weak) IBOutlet UIImageView *welcomeImageView;

- (void)show;

- (IBAction)didClickFinishButton:(UIButton *)sender;

@end
