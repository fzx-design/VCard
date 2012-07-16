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

@property (nonatomic, weak) IBOutlet UIView *dividerView;
@property (nonatomic, weak) IBOutlet UIImageView *leftpatternImageView;
@property (nonatomic, weak) IBOutlet UIImageView *rightpatternImageView;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) NSString *typeString;
@property (nonatomic, assign) NSInteger pageIndex;

- (void)setCellHeight:(CGFloat)height;
- (void)loadImageAfterScrollingStop;
- (void)resetDividerViewWithCommentCount:(int)commentCount;

@end
