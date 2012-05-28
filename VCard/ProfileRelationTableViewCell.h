//
//  ProfileTableUserCell.h
//  VCard
//
//  Created by 海山 叶 on 12-5-28.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserAvatarImageView.h"

@interface ProfileRelationTableViewCell : UITableViewCell {
    UserAvatarImageView *_avatarImageView;
    UILabel *_screenNameLabel;
    UILabel *_infoLabel;
    
    UIImageView *_cellSelectionImageView;
}

@property (nonatomic, strong) IBOutlet UserAvatarImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet UILabel *screenNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *infoLabel;

@property (nonatomic, strong) IBOutlet UIImageView *cellSelectionImageView;

@end
