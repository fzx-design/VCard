//
//  TopicImageView.h
//  VCard
//
//  Created by 海山 叶 on 12-7-4.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopicImageView : UIView {
    UIImageView *_photoFrameImageView;
    UIImageView *_imageView;
    UIImageView *_backImageView;
}

- (void)loadImageFromURL:(NSString *)urlString 
              completion:(void (^)())completion;

// Animation
- (void)swingOnce:(CALayer*)layer toAngle:(CGFloat)toAngle;
- (void)swingHalt:(CALayer*)layer fromAngle:(CGFloat)fromAngle;

@end
