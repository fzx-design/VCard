//
//  DividerViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-5-22.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DividerViewController : UIViewController {
    UIImageView *_leftPattern;
    UIImageView *_rightPattern;
    
    UILabel *_timeLabel;
}

@property (nonatomic, strong) IBOutlet UIImageView *leftPattern;
@property (nonatomic, strong) IBOutlet UIImageView *rightPattern;
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;

- (void)updateTimeInformation:(NSDate *)date;

@end
