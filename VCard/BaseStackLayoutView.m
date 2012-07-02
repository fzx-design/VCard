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
        
        _shadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-164.0, 0.0, 184.0, self.frame.size.height)];
//        _shadowImageView.image = [[UIImage imageNamed:kRLStackViewSideShadow] resizableImageWithCapInsets:UIEdgeInsetsZero];
        _shadowImageView.image = [UIImage imageNamed:kRLStackViewSideShadow];
        _shadowImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _shadowImageView.opaque = YES;
        self.opaque = YES;
        [self insertSubview:_shadowImageView atIndex:1];
    }
    return self;
}


@end
