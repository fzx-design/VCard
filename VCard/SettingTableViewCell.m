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

@synthesize delegate = _delegate;
@synthesize itemWatchButton = _itemWatchButton;
@synthesize itemSwitch = _itemSwitch;

- (id)init {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NSStringFromClass([self class])];
    if(self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:NO animated:animated];
}

- (void)setSwitch {
    self.itemSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 94, 27)];
    
    [self.itemSwitch addTarget:self action:@selector(didCLickSwitch:) forControlEvents:UIControlEventValueChanged];
    
    self.accessoryView = self.itemSwitch;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryNone;
}

- (void)setDisclosureIndicator {
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
    self.accessoryView = nil;
}

- (void)setWatchButton {
    self.itemWatchButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 32)];
    [self.itemWatchButton setBackgroundImage:[UIImage imageNamed:@"button_about_follow"] forState:UIControlStateNormal];
    [self.itemWatchButton setBackgroundImage:[UIImage imageNamed:@"button_about_followed"] forState:UIControlStateDisabled];
    
    [self.itemWatchButton setTitleColor:[UIColor colorWithRed:51. / 255 green:51. / 255 blue:51. / 255 alpha:1] forState:UIControlStateNormal];
    [self.itemWatchButton setTitleColor:[UIColor colorWithRed:130. / 255. green:130. / 255 blue:130. / 255 alpha:1] forState:UIControlStateDisabled];
    
    [self.itemWatchButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.itemWatchButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    
    [self.itemWatchButton setTitle:@"关注" forState:UIControlStateNormal];
    [self.itemWatchButton setTitle:@"已关注" forState:UIControlStateDisabled];
    
    [self.itemWatchButton addTarget:self action:@selector(didClickWatchButton:) forControlEvents:UIControlEventTouchUpInside];
    
    self.itemWatchButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    self.itemWatchButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
    
    self.accessoryView = self.itemWatchButton;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryNone;
}

- (void)didClickWatchButton:(UIButton *)sender {
    if([self.delegate respondsToSelector:@selector(settingTableViewCell:didClickWatchButton:)])
        [self.delegate settingTableViewCell:self didClickWatchButton:sender];
}

- (void)didCLickSwitch:(UISwitch *)sender {
    if([self.delegate respondsToSelector:@selector(settingTableViewCell:didChangeSwitch:)])
        [self.delegate settingTableViewCell:self didChangeSwitch:sender];
}

@end
