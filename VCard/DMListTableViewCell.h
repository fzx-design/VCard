//
//  DMListTableViewCell.h
//  VCard
//
//  Created by 海山 叶 on 12-7-21.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserAvatarImageView.h"

@interface DMListTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UserAvatarImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UILabel *screenNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *infoLabel;
@property (nonatomic, weak) IBOutlet UIImageView *cellSelectionImageView;
@property (nonatomic, weak) IBOutlet UIImageView *hasNewIndicator;

@end
