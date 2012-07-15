//
//  SearchTableViewCell.h
//  VCard
//
//  Created by 海山 叶 on 12-7-14.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel     *titleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *cellSelectionImageView;

- (void)setTitle:(NSString *)title;
- (void)setOperationTitle:(NSString *)title;

@end
