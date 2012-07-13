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
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setSwitch {
    self.itemSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 94, 27)];
    self.accessoryView = self.itemSwitch;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setDisclosureIndicator {
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
}

@end
