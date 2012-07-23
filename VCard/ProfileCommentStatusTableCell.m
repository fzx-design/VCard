//
//  ProfileCommentStatusTableCell.m
//  VCard
//
//  Created by Gabriel Yeah on 12-6-22.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "ProfileCommentStatusTableCell.h"
#import "UIView+Resize.h"

#define kLeftPatternOriginXAll 138.0
#define kLeftPatternOriginXFollowing 120.0
#define kLeftPatternOriginXNone 144.0
#define kRightPatternOriginXAll 215.0
#define kRightPatternOriginXFollowing 234.0
#define kRightPatternOriginXNone 210.0

@implementation ProfileCommentStatusTableCell

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
    frame.size.height = height + 36.0;
    self.frame = frame;
    
    frame = self.cardViewController.view.frame;
    frame.size.height = height;
    self.cardViewController.view.frame = frame;
}

- (void)resetDividerViewWithCommentCount:(int)commentCount
{
    [self.dividerView resetOriginY:self.frame.size.height - 40.0];
    NSString *description = commentCount == 0 ? [NSString stringWithFormat:@"无%@", _typeString] :
                                                    [NSString stringWithFormat:@"%i 条%@", commentCount, _typeString];
    
    CGFloat stringWidth = ceilf([description sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(1000.0, 30.0) lineBreakMode:UILineBreakModeWordWrap].width) + 1;
    
    CGFloat leftOriginX = 192.0 - stringWidth / 2 - 30.0;
    CGFloat rightOriginX = 192.0 + stringWidth / 2;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.descriptionLabel.text = description;
        [self.leftpatternImageView resetOriginX:leftOriginX];
        [self.rightpatternImageView resetOriginX:rightOriginX];
    }];
}

- (CardViewController*)cardViewController
{
    if (_cardViewController == nil) {
        
        _cardViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:NULL] instantiateViewControllerWithIdentifier:@"CardViewController"];
        
        CGRect frame = _cardViewController.view.frame;
        frame.origin = CGPointMake(10, 11);
        frame.size = CGSizeMake(362, 500);
        _cardViewController.view.frame = frame;
        _cardViewController.mustShowPic = YES;
        
        [self addSubview:_cardViewController.view];
    }
    return _cardViewController;
}

@end
