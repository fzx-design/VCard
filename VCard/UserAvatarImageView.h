//
//  UserAvatarImageView.h
//  VCard
//
//  Created by 海山 叶 on 12-5-25.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "UIImageViewAddition.h"

@interface UserAvatarImageView : UIView {
    UIImageView *_vipImageView;
    UIImageView *_photoFrameImageView;
    UIImageView *_imageView;
    UIImageView *_backImageView;
}

- (void)setVerifiedType:(VerifiedType)type;
- (void)reset;

- (void)loadImageFromURL:(NSString *)urlString 
              completion:(void (^)())completion;

// Animation
- (void)swingOnce:(CALayer*)layer toAngle:(CGFloat)toAngle;
- (void)swingHalt:(CALayer*)layer;

@end
