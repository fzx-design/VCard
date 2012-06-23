//
//  ProfileCommentStatusTableCell.h
//  VCard
//
//  Created by Gabriel Yeah on 12-6-22.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardViewController.h"
#import "CommentViewController.h"

@interface ProfileCommentStatusTableCell : UITableViewCell

@property (nonatomic, strong) CardViewController *cardViewController;

@property (nonatomic, strong) IBOutlet UIView *dividerView;
@property (nonatomic, strong) IBOutlet UIImageView *leftpatternImageView;
@property (nonatomic, strong) IBOutlet UIImageView *rightpatternImageView;
@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;

- (void)setCellHeight:(CGFloat)height;
- (void)loadImageAfterScrollingStop;
- (void)resetDividerViewWithCommentCount:(int)commentCount;

@end
