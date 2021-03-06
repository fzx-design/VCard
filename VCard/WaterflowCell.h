//
//  WaterflowCell.h
//  VCard
//
//  Created by 海山 叶 on 12-4-19.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardViewController.h"

#define kReuseIdentifierCardCell  @"kReuseIdentifierCardCell"
#define kReuseIdentifierDividerCell  @"kReuseIdentifierDividerCell"
#define kReuseIdentifierEmptyCell  @"kReuseIdentifierEmptyCell"

@interface WaterflowCell : UIView
{
    NSIndexPath *_indexPath;
    NSString *_reuseIdentifier;
}

@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, retain) NSString *reuseIdentifier;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier currentUser:(User*)currentUser_;
- (void)loadImageAfterScrollingStop;
- (void)prepareForReuse;
- (void)setCellHeight:(CGFloat)height;
- (void)resetLayoutAfterRotating;

@end