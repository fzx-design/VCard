//
//  UserAvatarImageView.h
//  VCard
//
//  Created by 海山 叶 on 12-5-25.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageViewAddition.h"

@interface UserAvatarImageView : UIImageView {
    UIImageView *_vipImageView;
    UIImageView *_photoFrameImageView;
}

- (void)setVerifiedType:(VerifiedType)type;
- (void)reset;

@end
