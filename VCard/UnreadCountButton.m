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
    int length = countString.length;
    
//    CGFloat fontSize = self.titleLabel.font.pointSize;
    int delta = 0;
    if (length > 2) {
        delta = (length - 2) * 4;
    }
    CGFloat width = 24.0 + delta;
    
    [self setTitle:countString forState:UIControlStateNormal];
    [self setTitle:countString forState:UIControlStateHighlighted];
    [self setTitle:countString forState:UIControlStateDisabled];
    [self resetWidth:width];
}

@end
