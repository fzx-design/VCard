//
//  ProfileStatusTableViewCell.m
//  VCard
//
//  Created by 海山 叶 on 12-5-31.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "ProfileStatusTableViewCell.h"

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
    frame.size.height = height;
    self.cardViewController.view.frame = frame;
}

- (CardViewController*)cardViewController
{
    if (_cardViewController == nil) {
        
        _cardViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:NULL] instantiateViewControllerWithIdentifier:@"CardViewController"];
        
        CGRect frame = _cardViewController.view.frame;
        frame.origin = CGPointMake(10, 5);
        frame.size = CGSizeMake(362, 500);
        _cardViewController.view.frame = frame;
        
        [self addSubview:_cardViewController.view];
    }
    return _cardViewController;
}

@end
