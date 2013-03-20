//
//  MyCell.h
//  VCard
//
//  Created by Emerson on 13-3-19.
//  Copyright (c) 2013年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCell : UITableViewCell

@property (copy, nonatomic) NSString * name;
@property (copy, nonatomic) NSString * color;

@property (strong, nonatomic) IBOutlet UILabel * nameLabel;
@property (strong, nonatomic) IBOutlet UILabel * colorLabel;

@end
