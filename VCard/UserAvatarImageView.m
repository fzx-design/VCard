//
//  UserAvatarImageView.m
//  VCard
//
//  Created by 海山 叶 on 12-5-25.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "UserAvatarImageView.h"
#import "UIImageView+URL.h"

#define IconBigFrame CGRectMake(70.0, 72.0, 27.0, 27.0)
#define IconSmallFrame CGRectMake(17.0, 17.0, 13.0, 14.0)

#define PhotoFrameFrame CGRectMake(-21.0, -38.0, 134.0, 160.0)

@implementation UserAvatarImageView

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
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(-1, -1, self.bounds.size.width + 2, self.bounds.size.height + 2)];
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
    if ([self isBigAvatar]) {
        _vipImageView = [[UIImageView alloc] initWithFrame:IconBigFrame];
        _photoFrameImageView = [[UIImageView alloc] initWithFrame:PhotoFrameFrame];
        _photoFrameImageView.image = [UIImage imageNamed:kRLProfileAvatarFrame];
        
        _photoFrameImageView.opaque = YES;
        
        [self addSubview:_photoFrameImageView];
        [self addSubview:_vipImageView];
    } else {
        _vipImageView = [[UIImageView alloc] initWithFrame:IconSmallFrame];
        
        [self addSubview:_vipImageView];
    }
    
    _vipImageView.opaque = YES;
    self.opaque = YES;
    
}

- (BOOL)isBigAvatar
{
    return self.frame.size.width > 50.0;
}

- (void)setVerifiedType:(VerifiedType)type
{
    switch (type) {
        case VerifiedTypeNone:
            _vipImageView.hidden = YES;
            break;
        case VerifiedTypePerson:
            _vipImageView.hidden = NO;
            _vipImageView.image = [self isBigAvatar] ? [UIImage imageNamed:kRLIconVerifiedPersionBig] : [UIImage imageNamed:kRLIconVerifiedPersonSmall];
            break;
        case VerifiedTypeAssociation:
            _vipImageView.hidden = NO;
            _vipImageView.image = [self isBigAvatar] ? [UIImage imageNamed:kRLIconVerifiedAssociationBig] : [UIImage imageNamed:kRLIconVerifiedAssociationSmall];
            break;
        case VerifiedTypeTalent:
            _vipImageView.hidden = NO;
            _vipImageView.image = [self isBigAvatar] ? [UIImage imageNamed:kRLIconVerifiedTalentBig] : [UIImage imageNamed:kRLIconVerifiedTalentSmall];
            
        default:
            break;
    }
}

- (void)loadImageFromURL:(NSString *)urlString 
              completion:(void (^)(BOOL succeeded))completion
{
    _imageView.image = [UIImage imageNamed:kRLAvatarPlaceHolderBG];
	
    [_imageView kv_cancelImageDownload];
    NSURL *anImageURL = [NSURL URLWithString:urlString];
    [_imageView kv_setImageAtURLWithoutCropping:anImageURL completion:^(BOOL succeeded) {
        if (completion) {
            completion(succeeded);
        }
        if (succeeded) {
            self.alpha = 0.0;
            [UIView animateWithDuration:0.3 animations:^{
                self.alpha = 1.0;
            }];
        }
    }];
}

- (void)reset
{
    _vipImageView.image = nil;
    _vipImageView.hidden = YES;
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

- (void)swingOnceThenHalt:(CALayer *)layer angle:(CGFloat)angle
{
    self.layer.anchorPoint = CGPointMake(0.5, -0.34);
    self.layer.position = CGPointMake(95.0, 90.0 - self.frame.size.height * 0.84);
    
    CAAnimationGroup* animationGroup = [CAAnimationGroup animation];
    NSMutableArray* animationArray = [NSMutableArray arrayWithCapacity:6];
    
    CABasicAnimation *readyAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    readyAnimation.toValue = [NSNumber numberWithFloat:angle];
    readyAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    readyAnimation.fillMode = kCAFillModeForwards;
    readyAnimation.removedOnCompletion = NO;
    readyAnimation.duration = 0.15;
    readyAnimation.beginTime = 0.0;
    
    [animationArray addObject:readyAnimation];
    
    for (int i = 0; i < 5; i++) {
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        rotationAnimation.toValue = [NSNumber numberWithFloat:((4-i)/5.0)*((4-i)/5.0)*angle*(-1+2*(i%2))];
        rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        rotationAnimation.fillMode = kCAFillModeForwards;
        rotationAnimation.removedOnCompletion = NO;
        rotationAnimation.duration = 0.4;
        rotationAnimation.beginTime = i * 0.4 + 0.15;
        
        [animationArray addObject:rotationAnimation];
    }
    [animationGroup setAnimations:animationArray];
    [animationGroup setDuration:2.15];
    
    [self.layer removeAllAnimations];
    [self.layer addAnimation:animationGroup forKey:@"swingAnimation"];
}

@end
