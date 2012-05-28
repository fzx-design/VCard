//
//  ProfileTableUserCell.m
//  VCard
//
//  Created by 海山 叶 on 12-5-28.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "ProfileRelationTableViewCell.h"

@implementation ProfileRelationTableViewCell

@synthesize avatarImageView = _avatarImageView;
@synthesize screenNameLabel = _screenNameLabel;
@synthesize infoLabel = _infoLabel;

@synthesize cellSelectionImageView = _cellSelectionImageView;

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
    self.cellSelectionImageView.hidden = !selected;
}

@end
