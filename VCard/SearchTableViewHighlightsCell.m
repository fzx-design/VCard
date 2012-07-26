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

- (void)setUpImages
{
    [_topImageView1 setImageViewWithName:@"topic_warm.png"];
    [_topImageView2 setImageViewWithName:@"topic_news.png"];
    [_topImageView3 setImageViewWithName:@"topic_funny.png"];
    [_topImageView4 setImageViewWithName:@"topic_food.png"];
    [_topImageView5 setImageViewWithName:@"topic_it.png"];
    [_topImageView6 setImageViewWithName:@"topic_sports.png"];
    
    UITapGestureRecognizer *gesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapTopicImage:)];
    gesture1.numberOfTapsRequired = 1;
    gesture1.numberOfTouchesRequired = 1;
    UITapGestureRecognizer *gesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapTopicImage:)];
    gesture2.numberOfTapsRequired = 1;
    gesture2.numberOfTouchesRequired = 1;
    UITapGestureRecognizer *gesture3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapTopicImage:)];
    gesture3.numberOfTapsRequired = 1;
    gesture3.numberOfTouchesRequired = 1;
    UITapGestureRecognizer *gesture4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapTopicImage:)];
    gesture4.numberOfTapsRequired = 1;
    gesture4.numberOfTouchesRequired = 1;
    UITapGestureRecognizer *gesture5 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapTopicImage:)];
    gesture5.numberOfTapsRequired = 1;
    gesture5.numberOfTouchesRequired = 1;
    UITapGestureRecognizer *gesture6 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapTopicImage:)];
    gesture6.numberOfTapsRequired = 1;
    gesture6.numberOfTouchesRequired = 1;
    [_topImageView1 addGestureRecognizer:gesture1];
    [_topImageView2 addGestureRecognizer:gesture2];
    [_topImageView3 addGestureRecognizer:gesture3];
    [_topImageView4 addGestureRecognizer:gesture4];
    [_topImageView5 addGestureRecognizer:gesture5];
    [_topImageView6 addGestureRecognizer:gesture6];
    
    [_topicLabel1 setText:@"温馨一刻"];
    [_topicLabel2 setText:@"时事新闻"];
    [_topicLabel3 setText:@"搞笑"];
    [_topicLabel4 setText:@"美食"];
    [_topicLabel5 setText:@"科技"];
    [_topicLabel6 setText:@"体育"];
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
                rotationAnimation.fromValue = @(angle);
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

- (void)didTapTopicImage:(UITapGestureRecognizer *)sender
{
    NSString *topicName = @"";
    if ([sender.view isEqual:_topImageView1]) {
        topicName = @"温馨一刻";
    } else if ([sender.view isEqual:_topImageView2]) {
        topicName = @"图片新闻";
    } else if ([sender.view isEqual:_topImageView3]) {
        topicName = @"搞笑图片";
    } else if ([sender.view isEqual:_topImageView4]) {
        topicName = @"美食";
    } else if ([sender.view isEqual:_topImageView5]) {
        topicName = @"IT新闻";
    } else if ([sender.view isEqual:_topImageView6]) {
        topicName = @"体育新闻";
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldShowTopic object:@{kNotificationObjectKeySearchKey: topicName, kNotificationObjectKeyIndex: [NSString stringWithFormat:@"%i", self.pageIndex]}];
    
}

@end
