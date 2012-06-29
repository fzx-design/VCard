//
//  UnreadCountButton.m
//  VCard
//
//  Created by 海山 叶 on 12-6-29.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "UnreadCountButton.h"
#import "ThemeResourceProvider.h"
#import "UIView+Resize.h"

@implementation UnreadCountButton

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
        [ThemeResourceProvider configButtonUnreadIndicator:self];
    }
    return self;
}

- (void)setCount:(int)count
{
    NSString *countString = [NSString stringWithFormat:@"%i", count];
    CGFloat fontSize = self.titleLabel.font.pointSize;
    CGFloat width = ceilf([countString sizeWithFont:[UIFont systemFontOfSize:fontSize]
                            constrainedToSize:CGSizeMake(30.0, 23.0)
                                      lineBreakMode:UILineBreakModeWordWrap].height) + 12.0;
    if (width < 26.0) {
        width = 26.0;
    }
    
    [self setTitle:countString forState:UIControlStateNormal];
    [self setTitle:countString forState:UIControlStateHighlighted];
    [self setTitle:countString forState:UIControlStateDisabled];
    [self resetWidth:width];
}

@end
