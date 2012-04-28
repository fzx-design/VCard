//
//  UIImageViewAddition.m
//  PushBox
//
//  Created by Xie Hasky on 11-7-28.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "UIImageViewAddition.h"

@implementation UIImageView (UIImageViewAddition)

- (void)loadImageFromURL:(NSString *)urlString 
              completion:(void (^)())completion
{
    
    self.image = nil;
	self.backgroundColor = [UIColor colorWithRed:181.0/255 green:181.0/255 blue:181.0/255 alpha:1.0];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloadQueue", NULL);
    
    dispatch_async(downloadQueue, ^{

        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        UIImage *img = [UIImage imageWithData:imageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            
			self.image = nil;
            self.image = img;
            
            if (completion) {
                completion();
            }				
        });
        [pool release];
        
    });
    
    dispatch_release(downloadQueue);
	
}

- (void)loadTweetImageFromURL:(NSString *)urlString 
              completion:(void (^)())completion
{
    
	self.backgroundColor = [UIColor colorWithRed:181.0/255 green:181.0/255 blue:181.0/255 alpha:1.0];
    self.image = nil;
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloadQueue", NULL);
    
    dispatch_async(downloadQueue, ^{
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        UIImage *img = [UIImage imageWithData:imageData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (img != nil) {
                self.image = nil;
                self.image = img;
            }
            
            if (completion) {
                completion();
            }
        });
        [pool release];
    });
    
    dispatch_release(downloadQueue);
	
}

@end
