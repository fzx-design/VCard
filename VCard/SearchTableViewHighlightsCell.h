//
//  SearchTableViewHighlightsCell.h
//  VCard
//
//  Created by 海山 叶 on 12-7-14.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopicImageView.h"

@interface SearchTableViewHighlightsCell : UITableViewCell

@property (nonatomic, strong) IBOutlet TopicImageView   *topImageView1;
@property (nonatomic, strong) IBOutlet TopicImageView   *topImageView2;
@property (nonatomic, strong) IBOutlet TopicImageView   *topImageView3;
@property (nonatomic, strong) IBOutlet TopicImageView   *topImageView4;
@property (nonatomic, strong) IBOutlet TopicImageView   *topImageView5;
@property (nonatomic, strong) IBOutlet TopicImageView   *topImageView6;

@property (nonatomic, strong) IBOutlet UILabel          *topicLabel1;
@property (nonatomic, strong) IBOutlet UILabel          *topicLabel2;
@property (nonatomic, strong) IBOutlet UILabel          *topicLabel3;
@property (nonatomic, strong) IBOutlet UILabel          *topicLabel4;
@property (nonatomic, strong) IBOutlet UILabel          *topicLabel5;
@property (nonatomic, strong) IBOutlet UILabel          *topicLabel6;


@property (nonatomic, strong) NSMutableArray *topicImageViewArray;
@property (nonatomic, strong) NSMutableArray *topicLabelArray;

- (void)swingWithAngle:(CGFloat)angle;
- (void)setUpImages;

@end
