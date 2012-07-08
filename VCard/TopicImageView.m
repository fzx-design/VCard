//
//  TopicImageView.m
//  VCard
//
//  Created by 海山 叶 on 12-7-4.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TopicImageView.h"
#import "UIImageView+URL.h"

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
              completion:(void (^)())completion
{
    _imageView.image = [UIImage imageNamed:kRLAvatarPlaceHolderBG];
	
    [_imageView kv_cancelImageDownload];
    NSURL *anImageURL = [NSURL URLWithString:urlString];
    [_imageView kv_setImageAtURLWithoutCropping:anImageURL completion:completion];
}

#pragma mark - Animation

- (void)swingOnce:(CALayer*)layer toAngle:(CGFloat)toAngle
{
    self.layer.anchorPoint = CGPointMake(0.5, -0.34);
    self.layer.position = CGPointMake(95.0, 90.0 - self.frame.size.height * 0.84);
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:toAngle];
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    rotationAnimation.fillMode = kCAFillModeForwards;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.duration = 0.1;
    
    [self.layer removeAllAnimations];
    [self.layer addAnimation:rotationAnimation forKey:@"swingAnimation"];
}

- (void)swingHalt:(CALayer *)layer fromAngle:(CGFloat)fromAngle
{
    self.layer.anchorPoint = CGPointMake(0.5, -0.34);
    self.layer.position = CGPointMake(95.0, 90.0 - self.frame.size.height * 0.84);
    
    CAAnimationGroup* animationGroup = [CAAnimationGroup animation];
    NSMutableArray* animationArray = [NSMutableArray arrayWithCapacity:5];
    
    for (int i = 0; i < 5; i++) {
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        rotationAnimation.toValue = [NSNumber numberWithFloat:((4-i)/5.0)*((4-i)/5.0)*fromAngle*(-1+2*(i%2))];
        rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        rotationAnimation.fillMode = kCAFillModeForwards;
        rotationAnimation.removedOnCompletion = NO;
        rotationAnimation.duration = 0.4;
        rotationAnimation.beginTime = i * 0.4;
        
        if (i == 0) {
            rotationAnimation.fromValue = [NSNumber numberWithFloat:fromAngle];
        }
        
        [animationArray addObject:rotationAnimation];
    }
    [animationGroup setAnimations:animationArray];
    [animationGroup setDuration:2.0];
    
    [self.layer removeAllAnimations];
    [self.layer addAnimation:animationGroup forKey:@"swingAnimation"];
}

@end
