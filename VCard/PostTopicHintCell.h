//
//  PostTopicHintCell.h
//  VCard
//
//  Created by 紫川 王 on 12-5-31.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostTopicHintCell : UITableViewCell

@property (nonatomic, strong) UIColor *defaultHintTextColor;
@property (nonatomic, weak) IBOutlet UILabel *hintTextLabel;

@end
