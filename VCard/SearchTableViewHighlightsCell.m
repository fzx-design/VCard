//
//  SearchTableViewHighlightsCell.m
//  VCard
//
//  Created by 海山 叶 on 12-7-14.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "SearchTableViewHighlightsCell.h"
#import "UIView+Swing.h"
#import <QuartzCore/QuartzCore.h>

#define kFirstRowTopicImageViewOriginY 38.0
#define kSecondRowTopicImageViewOriginY 207.0

@implementation SearchTableViewHighlightsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)swingWithAngle:(CGFloat)angle
{
    int i = 0;
    for (UIView *view in self.topicImageViewArray) {
        CGFloat originY = i++ < 3 ? kFirstRowTopicImageViewOriginY : kSecondRowTopicImageViewOriginY;
        
        CGPoint point = CGPointMake(view.frame.origin.x + view.frame.size.width / 2, originY);
        
        view.layer.anchorPoint = CGPointMake(0.5, 0.05);
        view.layer.position = point;
        
        CAAnimationGroup* animationGroup = [CAAnimationGroup animation];
        NSMutableArray* animationArray = [NSMutableArray arrayWithCapacity:5];
        
        for (int i = 0; i < 5; i++) {
            CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
            rotationAnimation.toValue = [NSNumber numberWithFloat:((4-i)/5.0)*((4-i)/5.0)*angle*(-1+2*(i%2))];
            rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            rotationAnimation.fillMode = kCAFillModeForwards;
            rotationAnimation.removedOnCompletion = NO;
            rotationAnimation.duration = 0.4;
            rotationAnimation.beginTime = i * 0.4;
            
            if (i == 0) {
                rotationAnimation.fromValue = [NSNumber numberWithFloat:angle];
            }
            
            [animationArray addObject:rotationAnimation];
        }
        [animationGroup setAnimations:animationArray];
        [animationGroup setDuration:2.0];
        
        [view.layer removeAllAnimations];
        [view.layer addAnimation:animationGroup forKey:@"swingAnimation"];
    }
}

- (NSMutableArray *)topicImageViewArray
{
    if (!_topicImageViewArray) {
        _topicImageViewArray = [NSMutableArray arrayWithObjects:_topImageView1,_topImageView2, _topImageView3, _topImageView4, _topImageView5, _topImageView6, nil];
    }
    return _topicImageViewArray;
}

- (NSMutableArray *)topicLabelArray
{
    if (!_topicLabelArray) {
        _topicLabelArray = [NSMutableArray arrayWithObjects:_topicLabel1,_topicLabel2, _topicLabel3, _topicLabel4, _topicLabel5, _topicLabel6, nil];
    }
    return _topicLabelArray;
}

@end
