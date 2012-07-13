//
//  UIImage+animatedImageWithGIF.h
//
//  Created by YuAo on 2/24/12.
//  Copyright (c) 2012 eico design. All rights reserved.
//
//  Note: 
//        ImageIO.framework is needed.
//        This lib is only available on iOS 5

#import <Foundation/Foundation.h>

@interface UIImage(animatedImageWithGIF)
+ (UIImage *)animatedImageWithGIFData:(NSData *)data;
+ (UIImage *)animatedImageWithGIFURL:(NSURL *)url;
@end
