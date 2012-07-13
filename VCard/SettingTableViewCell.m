//
//  SettingTableViewCell.m
//  WeTongji
//
//  Created by 紫川 王 on 12-4-24.
//  Copyright (c) 2012年 Tongji Apple Club. All rights reserved.
//

#import "SettingTableViewCell.h"
#import "UIView+Resize.h"

@implementation SettingTableViewCell

@synthesize itemSwitch = _itemSwitch;

- (id)init {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NSStringFromClass([self class])];
    if(self) {
        self.itemSwitch = [[UISwitch alloc] init];
        [self.itemSwitch resetOriginX:self.contentView.frame.size.width - self.itemSwitch.frame.size.width - self.imageView.frame.origin.x];
        self.itemSwitch.autoresizingMask = !UIViewAutoresizingFlexibleRightMargin;
        [self.contentView addSubview:self.itemSwitch];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
