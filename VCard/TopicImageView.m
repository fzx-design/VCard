//
//  TopicImageView.m
//  VCard
//
//  Created by 海山 叶 on 12-7-4.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TopicImageView.h"
#import "UIView+Resize.h"
#import "UIImageView+Addition.h"

#define PhotoFrameFrame CGRectMake(-18.0, -10.0, 120, 114)

@implementation TopicImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [_imageView resetOriginX:_imageView.frame.origin.x - 1];
        [_imageView resetOriginY:_imageView.frame.origin.y - 1];
        [_imageView resetWidth:_imageView.frame.size.width + 2];
        [_imageView resetHeight:_imageView.frame.size.width + 2];
        _backImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _backImageView.image = [UIImage imageNamed:kRLAvatarPlaceHolderBG];
        [self addSubview:_backImageView];
        [self addSubview:_imageView];
        [self setUpVIPImageView];
    }
    return self;
}

- (void)setUpVIPImageView
{
    _photoFrameImageView = [[UIImageView alloc] initWithFrame:PhotoFrameFrame];
    _photoFrameImageView.image = [UIImage imageNamed:@"topic_pic_frame.png"];
    _photoFrameImageView.opaque = YES;
        
    [self addSubview:_photoFrameImageView];
    self.opaque = YES;
    
}

- (BOOL)isBigAvatar
{
    return self.frame.size.width > 50.0;
}

- (void)loadImageFromURL:(NSString *)urlString 
              completion:(void (^)(BOOL succeeded))completion
{
    _imageView.image = [UIImage imageNamed:kRLAvatarPlaceHolderBG];
	
    [_imageView loadImageFromURL:urlString completion:completion];
}

- (void)setImageViewWithName:(NSString *)imageName
{
    _imageView.image = [UIImage imageNamed:imageName];
}

@end
