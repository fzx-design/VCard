//
//  PostHintCell.m
//  VCard
//
//  Created by 紫川 王 on 12-5-31.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "PostAtHintCell.h"

@interface PostAtHintCell()

@end

@implementation PostAtHintCell

@synthesize avatarImageView = _avatarImageView;

- (void)awakeFromNib {
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
