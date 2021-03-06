//
//  UIImage+Addition.h
//  VCard
//
//  Created by 海山 叶 on 12-5-20.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+ProportionalFill.h"

@interface UIImage (Addition)

- (UIImage *)motionsAdjustImage;
- (UIImage *)rotateAdjustImage;
- (UIImage *)compressImageToSize:(CGSize)size;

- (UIImage *)brightness:(CGFloat)brightness contrast:(CGFloat)contrast;
- (UIImage *)shadowAmount:(CGFloat)shadowAmountValue;
+ (UIImage *)shadowAmount:(CGFloat)shadowAmountValue withCIImage:(CIImage *)source;

- (UIImage *)imageAtRect:(CGRect)rect;
- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize;
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

- (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize;
- (UIImage *)scaleImageToSize:(CGSize)newSize;
+ (UIImage *)screenShot;

+ (void)loadSettingAvatarImageFromURL:(NSString *)avatarURL
                           completion:(void (^)(UIImage *result))completion;

@end
