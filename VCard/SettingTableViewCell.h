//
//  SettingTableViewCell.h
//  WeTongji
//
//  Created by 紫川 王 on 12-4-24.
//  Copyright (c) 2012年 Tongji Apple Club. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingTableViewCellDelegate;

@interface SettingTableViewCell : UITableViewCell

@property (nonatomic, weak) id<SettingTableViewCellDelegate> delegate;
@property (nonatomic, strong) UISwitch *itemSwitch;
@property (nonatomic, strong) UIButton *itemWatchButton;

- (void)setSwitch;
- (void)setDisclosureIndicator;
- (void)setWatchButton;

@end

@protocol SettingTableViewCellDelegate <NSObject>

@optional
- (void)settingTableViewCell:(SettingTableViewCell *)cell didClickWatchButton:(UIButton *)sender;
- (void)settingTableViewCell:(SettingTableViewCell *)cell didChangeSwitch:(UISwitch *)sender;

@end
