//
//  BaseStackLayoutView.m
//  VCard
//
//  Created by 海山 叶 on 12-5-26.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "BaseStackLayoutView.h"

@implementation BaseStackLayoutView

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
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.image = [[UIImage imageNamed:kRLStackViewBGUnit] resizableImageWithCapInsets:UIEdgeInsetsZero];
    }
    return self;
}


@end
