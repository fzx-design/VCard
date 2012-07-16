//
//  ProfileTableUserCell.m
//  VCard
//
//  Created by 海山 叶 on 12-5-28.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "ProfileRelationTableViewCell.h"

@implementation ProfileRelationTableViewCell

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
    self.cellSelectionImageView.hidden = YES;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    self.cellSelectionImageView.hidden = !highlighted;
}

@end
