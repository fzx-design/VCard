//
//  FilterImageView.h
//  VCard
//
//  Created by 紫川 王 on 12-4-18.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface FilterImageView : GLKView {
    GLuint _renderBuffer;
}

@property (nonatomic, assign) float shadowAmountValue;

- (void)setImage:(UIImage *)image;
- (void)initializeParameter;

@end
