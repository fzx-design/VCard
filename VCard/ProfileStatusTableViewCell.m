//
//  ProfileStatusTableViewCell.m
//  VCard
//
//  Created by 海山 叶 on 12-5-31.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "ProfileStatusTableViewCell.h"
#import "UIView+Resize.h"

@implementation ProfileStatusTableViewCell

@synthesize cardViewController = _cardViewController;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)loadImageAfterScrollingStop
{
    [self.cardViewController loadImage];
}

- (void)prepareForReuse
{
    [self.cardViewController prepareForReuse];
}

- (void)setCellHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
    
    frame = self.cardViewController.view.frame;
    frame.size.height = height - kCardGapOffset;
    self.cardViewController.view.frame = frame;
}

- (CardViewController*)cardViewController
{
    if (_cardViewController == nil) {
        
        _cardViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:NULL] instantiateViewControllerWithIdentifier:@"CardViewController"];
        
        [_cardViewController.view resetOrigin:CGPointMake(10, 15)];
        [_cardViewController.view resetSize:CGSizeMake(362, 500)];
        
        [self addSubview:_cardViewController.view];
    }
    return _cardViewController;
}

@end
