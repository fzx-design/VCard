//
//  CardImageView.m
//  VCard
//
//  Created by 海山 叶 on 12-4-14.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "CardImageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation CardImageView

@synthesize imageView = _imageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _shadowView = [[CardImageViewShadowView alloc] initWithFrame:frame];
        [self insertSubview:_shadowView atIndex:0];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _shadowView = [[CardImageViewShadowView alloc] initWithFrame:self.frame];
        [self insertSubview:_shadowView atIndex:0];
        [self insertSubview:self.imageView atIndex:1];
        self.clearsContextBeforeDrawing = YES;
    }
    return self;
}

- (void)resetHeight:(CGFloat)height
{
    [_shadowView removeFromSuperview];
    _shadowView = nil;
    
    CGRect frame = CGRectMake(-4.0, 13.0, StatusImageWidth, height);
    self.transform = CGAffineTransformMakeRotation(0);
    self.frame = frame;
    
    frame.origin = CGPointMake(0.0, 0.0);
    self.imageView.frame = frame;

    _shadowView = [[CardImageViewShadowView alloc] initWithFrame:self.frame];
    [self insertSubview:_shadowView aboveSubview:self.imageView];
    
    CGFloat rotatingDegree = (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * 4) - 2;
    self.transform = CGAffineTransformMakeRotation(rotatingDegree * M_PI / 180);
}

- (UIImageView*)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.frame];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.backgroundColor = [UIColor colorWithRed:181.0/255 green:181.0/255 blue:181.0/255 alpha:1.0];
        [self insertSubview:_imageView belowSubview:_shadowView];
    }
    return _imageView;
}

- (void)loadImageFromURL:(NSString *)urlString 
              completion:(void (^)())completion
{
    
    self.imageView.image = nil;
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloadQueue", NULL);
    
    dispatch_async(downloadQueue, ^{
        
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        UIImage *img = [UIImage imageWithData:imageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            
			self.imageView.image = nil;
            self.imageView.image = img;
            
            if (completion) {
                completion();
            }				
        });
        
    });
    
    dispatch_release(downloadQueue);
	
}

- (void)loadTweetImageFromURL:(NSString *)urlString 
                   completion:(void (^)())completion
{
    
//    self.backgroundColor = [UIColor colorWithRed:181.0/255 green:181.0/255 blue:181.0/255 alpha:1.0];
    self.imageView.image = nil;
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("downloadQueue", NULL);
    
    dispatch_async(downloadQueue, ^{
        
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        UIImage *img = [UIImage imageWithData:imageData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (img != nil) {
                self.imageView.image = nil;
                self.imageView.image = img;
            }
            
            if (completion) {
                completion();
            }
        });
    });
    
    dispatch_release(downloadQueue);
	
}

- (void)clearCurrentImage
{
    self.imageView.image = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
