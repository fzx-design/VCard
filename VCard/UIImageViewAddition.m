//
//  UIImageViewAddition.m
//  PushBox
//
//  Created by Xie Hasky on 11-7-28.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "UIImageViewAddition.h"
#import "UIImageView+URL.h"

@implementation UIImageView (UIImageViewAddition)

- (void)loadImageFromURL:(NSString *)urlString 
              completion:(void (^)())completion
{
    self.image = [UIImage imageNamed:kRLAvatarPlaceHolderBG];
	
    [self kv_cancelImageDownload];
    NSURL *anImageURL = [NSURL URLWithString:urlString];
    [self kv_setImageAtURLWithoutCropping:anImageURL completion:completion];
}

@end
