//
//  ProfileTableUserCell.h
//  VCard
//
//  Created by 海山 叶 on 12-5-28.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserAvatarImageView.h"

@interface ProfileRelationTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UserAvatarImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UILabel *screenNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *infoLabel;

@property (nonatomic, weak) IBOutlet UIImageView *cellSelectionImageView;

@end
