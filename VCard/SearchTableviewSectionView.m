//
//  SearchTableviewSectionView.m
//  VCard
//
//  Created by 海山 叶 on 12-7-14.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "SearchTableviewSectionView.h"
#import "UIView+Resize.h"

@implementation SearchTableviewSectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _backgroundView = [[UIImageView alloc] initWithFrame:frame];
        _backgroundView.image = [UIImage imageNamed:@"section_bar_bg.png"];
        
        _titleLabel = [[UILabel alloc] initWithFrame:frame];
        [_titleLabel resetOriginX:15.0];
        [_titleLabel resetOriginY:_titleLabel.frame.origin.y - 1];
        _titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
        _titleLabel.shadowColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        _titleLabel.textColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.75];
        _titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        _titleLabel.backgroundColor = [UIColor clearColor];
        
        [self addSubview:_backgroundView];
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
}

@end
