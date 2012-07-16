//
//  DividerViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-5-22.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DividerViewController : UIViewController 

@property (nonatomic, weak) IBOutlet UIImageView *leftPattern;
@property (nonatomic, weak) IBOutlet UIImageView *rightPattern;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;

- (void)updateTimeInformation:(NSDate *)date;

@end
