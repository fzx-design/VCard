//
//  UIImage+animatedImageWithGIF.m
//
//  Created by YuAo on 2/24/12.
//  Copyright (c) 2012 eico design. All rights reserved.
//

#import "UIImage+animatedImageWithGIF.h"
#import <ImageIO/ImageIO.h>

#if __has_feature(objc_arc)
    #define toCF (__bridge CFTypeRef)
#else
    #define toCF (CFTypeRef)
#endif

@implementation UIImage(animatedImageWithGIF)

+ (UIImage *)animatedImageWithAnimatedGIFImageSource:(CGImageSourceRef) source 
                                         andDuration:(NSTimeInterval) duration {
    if (!source) return nil;
    size_t count = CGImageSourceGetCount(source);
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:count];
    for (size_t i = 0; i < count; ++i) {
        CGImageRef cgImage = CGImageSourceCreateImageAtIndex(source, i, NULL);
        if (!cgImage)
            return nil;
        [images addObject:[UIImage imageWithCGImage:cgImage]];
        CGImageRelease(cgImage);
    }
    
    NSLog(@"%zd images for gif", count);
    return [UIImage animatedImageWithImages:images duration:duration];
}

+ (NSTimeInterval)durationForGifData:(NSData *)data {
    char graphicControlExtensionStartBytes[] = {0x21,0xF9,0x04};
    double duration=0;
    NSRange dataSearchLeftRange = NSMakeRange(0, data.length);
    while(YES){
        NSRange frameDescriptorRange = [data rangeOfData:[NSData dataWithBytes:graphicControlExtensionStartBytes 
                                                                        length:3] 
                                                 options:NSDataSearchBackwards
                                                   range:dataSearchLeftRange];
        if (frameDescriptorRange.location!=NSNotFound){
            NSData *durationData = [data subdataWithRange:NSMakeRange(frameDescriptorRange.location+4, 2)];
            unsigned char buffer[2];
            [durationData getBytes:buffer];
            double delay = (buffer[0] | buffer[1] << 8);
            duration += delay;
            dataSearchLeftRange = NSMakeRange(0, frameDescriptorRange.location);
        }else{
            break;
        }
    }
    
    while (duration > 30.0) {
        duration /= 100.0;
    }
    
    NSLog(@"%f seconds interval for gif", duration);
    return duration;
}

+ (UIImage *)animatedImageWithGIFData:(NSData *)data{
    NSTimeInterval duration = [self durationForGifData:data];
    CGImageSourceRef source = CGImageSourceCreateWithData(toCF data, NULL);
    UIImage *image = [UIImage animatedImageWithAnimatedGIFImageSource:source andDuration:duration]; 
    CFRelease(source);
    return image;
}

+ (UIImage *)animatedImageWithGIFURL:(NSURL *)url{
    NSData *data = [NSData dataWithContentsOfURL:url];
    return [UIImage animatedImageWithGIFData:data];
}

@end
