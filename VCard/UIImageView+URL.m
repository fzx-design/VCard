//
//  UIImageView+URL.m
//  Koolistov
//
//  Created by Johan Kool on 28-10-10.
//  Copyright 2010-2011 Koolistov. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are 
//  permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this list of 
//    conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice, this list 
//    of conditions and the following disclaimer in the documentation and/or other materials 
//    provided with the distribution.
//  * Neither the name of KOOLISTOV nor the names of its contributors may be used to 
//    endorse or promote products derived from this software without specific prior written 
//    permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
//  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
//  THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT 
//  OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
//  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "UIImageView+URL.h"
#import "UIImage+Addition.h"

#import "KVImageCache.h"
#import "KVDownload.h"

#define kActivityIndicatorTag 18942347

@implementation UIImageView (URL)

- (void)kv_showActivityIndicatorWithStyle:(UIActivityIndicatorViewStyle)indicatorStyle {
    // Ensure we don't get multiple spinners
    [[self viewWithTag:kActivityIndicatorTag] removeFromSuperview];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:indicatorStyle];

    activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    CGRect currentFrame = activityIndicator.frame;
    CGRect newFrame = CGRectMake(CGRectGetMidX(self.bounds) - 0.5f * currentFrame.size.width,
                                 CGRectGetMidY(self.bounds) - 0.5f * currentFrame.size.height,
                                 currentFrame.size.width,
                                 currentFrame.size.height);
    activityIndicator.frame = newFrame;
    activityIndicator.tag = kActivityIndicatorTag;
    [activityIndicator startAnimating];
    [self addSubview:activityIndicator];
    [activityIndicator release];
}

- (void)kv_hideActivityIndicator {
    UIView *activityIndicator = [self viewWithTag:kActivityIndicatorTag];

    [activityIndicator removeFromSuperview];
}

- (void)kv_setImageAtURL:(NSURL *)imageURL {
    [self kv_setImageAtURL:imageURL 
     showActivityIndicator:YES 
    activityIndicatorStyle:UIActivityIndicatorViewStyleGray 
              loadingImage:nil 
         notAvailableImage:nil];
}

- (void)kv_setImageAtURL:(NSURL *)imageURL 
   showActivityIndicator:(BOOL)showActivityIndicator 
  activityIndicatorStyle:(UIActivityIndicatorViewStyle)indicatorStyle 
            loadingImage:(UIImage *)loadingImage 
       notAvailableImage:(UIImage *)notAvailableImage 
{
    [self kv_setImageAtURL:imageURL 
                  cacheURL:imageURL 
     showActivityIndicator:showActivityIndicator 
    activityIndicatorStyle:indicatorStyle 
              loadingImage:loadingImage 
         notAvailableImage:notAvailableImage];
}

- (void)kv_setImageAtURL:(NSURL *)imageURL 
                cacheURL:(NSURL *)cacheURL 
   showActivityIndicator:(BOOL)showActivityIndicator
  activityIndicatorStyle:(UIActivityIndicatorViewStyle)indicatorStyle 
            loadingImage:(UIImage *)loadingImage 
       notAvailableImage:(UIImage *)notAvailableImage 
{
    NSAssert([NSThread isMainThread], @"This method should be called from the main thread.");
    // Cancel any previous downloads
    [[KVImageCache defaultCache] cancelDownloadForImageView:self];    
    [self kv_hideActivityIndicator];
    
    CGSize imageSizeWithBorder = CGSizeMake(self.frame.size.width + 2, self.frame.size.height + 2);
    UIImage *tmpImage = [loadingImage imageByScalingAndCroppingForSize:imageSizeWithBorder];
    
    UIGraphicsBeginImageContext(imageSizeWithBorder);
    [tmpImage drawInRect:(CGRect){{1, 1}, self.frame.size}];
    [self setImage:UIGraphicsGetImageFromCurrentImageContext()];
    UIGraphicsEndImageContext();

    if (!imageURL) {
        self.image = notAvailableImage;
        return;
    }
    
    if (showActivityIndicator) {
        [self kv_showActivityIndicatorWithStyle:indicatorStyle];
    }
    
    [[KVImageCache defaultCache] loadImageAtURL:imageURL cacheURL:cacheURL imageView:self withHandler:^(UIImage * image) {
        
        dispatch_queue_t downloadQueue = dispatch_queue_create("downloadQueue", NULL);
        
        dispatch_async(downloadQueue, ^{
            
            UIImage *targetImage = nil;
            
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            if (!image) {
                self.image = notAvailableImage;
            } else {
                CGSize imageSizeWithBorder = CGSizeMake(self.frame.size.width + 2, self.frame.size.height + 2);
                UIImage *tmpImage = [image imageByScalingAndCroppingForSize:imageSizeWithBorder];
                
                UIGraphicsBeginImageContext(imageSizeWithBorder);
                [tmpImage drawInRect:(CGRect){{1, 1}, self.frame.size}];
                targetImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (image) {
                    [self setImage:targetImage];
                }
                
                if (showActivityIndicator) {
                    [self performSelectorOnMainThread:@selector(kv_hideActivityIndicator) withObject:nil waitUntilDone:NO];
                }
            });
            [pool release];
            
        });
        
        dispatch_release(downloadQueue);
        

     }];
}

- (void)kv_cancelImageDownload {
    NSAssert([NSThread isMainThread], @"This method should be called from the main thread.");
    [self kv_hideActivityIndicator];
    [[KVImageCache defaultCache] cancelDownloadForImageView:self];
}

@end
