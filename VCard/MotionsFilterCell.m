//
//  MotionsFilterCell.m
//  WeTongji
//
//  Created by 紫川 王 on 12-5-10.
//  Copyright (c) 2012年 Tongji Apple Club. All rights reserved.
//

#import "MotionsFilterCell.h"

@implementation MotionsFilterCell

@synthesize thumbnailImageView = _thumbnailImageView;

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
