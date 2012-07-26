//
//  CardImageView.m
//  VCard
//
//  Created by 海山 叶 on 12-4-14.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "CardImageView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+Resize.h"
#import "UIApplication+Addition.h"
#import "UIImage+animatedImageWithGIF.h"
#import "ErrorIndicatorViewController.h"
#import "UIView+Addition.h"
#import "InnerBrowserViewController.h"
#import "UIImageView+AFNetworking.h"

@interface CardImageView ()

@property (nonatomic, assign) CGFloat                   deltaWidth;
@property (nonatomic, assign) CGFloat                   deltaHeight;
@property (nonatomic, strong) UIActivityIndicatorView   *activityIndicatiorView;
@property (nonatomic, strong) UIImage                   *staticGIFImage;

@end


@implementation CardImageView {
    ErrorIndicatorViewController *_errorIndicateViewController;
}

@synthesize imageView = _imageView;
@synthesize gifIcon = _gifIcon;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _shadowView = [[CardImageViewShadowView alloc] initWithFrame:frame];
        [self insertSubview:_shadowView atIndex:0];
        self.imageView.layer.edgeAntialiasingMask = 0;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self insertSubview:self.imageView atIndex:1];
        self.clearsContextBeforeDrawing = YES;
        self.imageView.layer.edgeAntialiasingMask = 0;
    }
    return self;
}

- (void)resetHeight:(CGFloat)height
{
    CGRect frame = CGRectMake(-4.0, 13.0, StatusImageWidth, height);
    self.transform = CGAffineTransformMakeRotation(0);
    self.frame = frame;
    
    frame.origin = CGPointMake(0.0, 0.0);
    self.imageView.frame = frame;
    
    _initialSize = self.imageView.frame.size;
    _initialFrame = self.layer.frame;
    
    self.coverView.frame = frame;
    [self.coverView resetOriginXByOffset:- 5.0];
    [self.coverView resetOriginYByOffset:- 4.0];
    [self.coverView resetWidthByOffset:10.0];
    [self.coverView resetHeightByOffset:10.0];
    self.activityIndicatiorView.center = self.coverView.center;
    
    CGFloat rotatingDegree = (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * 4) - 2;
    _initialRotation = rotatingDegree * M_PI / 180;
    self.transform = CGAffineTransformMakeRotation(_initialRotation);
    
    _initialPosition = self.frame.origin;
    
    [self.actionButton resetCenterX:self.center.x + 4];
    [self.actionButton resetCenterY:self.center.y - 12];
}

- (void)pinchResizeToScale:(CGFloat)scale
{
    scale -= 1.0;
    if (scale >= 0.5) {
        scale = 0.5;
    }
    if (scale > 0.0) {
        scale /= 0.5;
        if (_deltaWidth > 0.0) {
            [self.imageView resetWidth:_initialSize.width + scale * _deltaWidth];
            [self.coverView resetWidth:self.imageView.frame.size.width + 10.0];
        } else {
            [self.imageView resetHeight:_initialSize.height + scale * _deltaHeight];
            [self.coverView resetHeight:self.imageView.frame.size.height + 10.0];
        }
    }
}

- (void)resetCurrentScale
{
    _currentScale = sqrt(self.transform.a * self.transform.a + self.transform.c * self.transform.c);
    _initialScale = _currentScale;
}

- (CGFloat)scaleOffset
{
    CGFloat offset = _currentScale - _initialScale;
    return offset;
}

- (void)playReturnAnimation
{
    if (_isGIF) {
        self.imageView.image = _staticGIFImage;
    }
    
    self.transform = CGAffineTransformIdentity;
    [self.imageView resetSize:_initialSize];
    [self.coverView resetSize:CGSizeMake(_initialSize.width + 10.0, _initialSize.height + 10.0)];
}

- (void)returnToInitialPosition
{
    [_errorIndicateViewController dismissViewAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }];
    _errorIndicateViewController = nil;
    
    [self resetSize:_initialSize];
    [self resetOrigin:_initialPosition];
    
    __block __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.transform = CGAffineTransformMakeRotation(_initialRotation);
    }];
}

- (void)loadImageFromURL:(NSString *)urlString 
              completion:(void (^)())completion
{
    _loadingCompleted = NO;
    _activityIndicatiorView.hidden = NO;
    [_activityIndicatiorView startAnimating];
    [self setUpGifIcon:urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    __block __weak typeof(self) weakSelf = self;
    CGRect targetFrame = self.imageView.frame;
    
    void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        
        weakSelf.imageView.image = image;
        weakSelf.staticGIFImage = image;
        
        CGFloat targetWidth = targetFrame.size.width;
        CGFloat targetHeight = targetFrame.size.height;
        CGFloat width = image.size.width;
        CGFloat height = image.size.height;
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        CGFloat scaleFactor = 0.0;
        
        CGFloat scaledWidth = 0.0;
        CGFloat scaledHeight = 0.0;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        weakSelf.deltaWidth = scaledWidth - targetWidth;
        weakSelf.deltaHeight = scaledHeight - targetHeight;
        
        widthFactor = 1024.0 / scaledWidth;
        heightFactor = 768.0 / scaledHeight;
        
        if (widthFactor > heightFactor)
            weakSelf.targetHorizontalScale = heightFactor; // scale to fit height
        else
            weakSelf.targetHorizontalScale = widthFactor; // scale to fit width
        
        widthFactor = 768.0 / scaledWidth;
        heightFactor = 1024.0 / scaledHeight;
        
        if (widthFactor > heightFactor)
            weakSelf.targetVerticalScale = heightFactor; // scale to fit height
        else
            weakSelf.targetVerticalScale = widthFactor; // scale to fit width
        
        weakSelf.loadingCompleted = YES;
        
        for (UIGestureRecognizer *gestureRecognizer in self.gestureRecognizers) {
            gestureRecognizer.enabled = YES;
        }
        
        weakSelf.imageView.alpha = 0.0;
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.imageView.alpha = 1.0;
        }];
        
        [weakSelf.activityIndicatiorView stopAnimating];
        weakSelf.activityIndicatiorView.hidden = YES;
    };
    
    void (^failBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [weakSelf.activityIndicatiorView stopAnimating];
        weakSelf.activityIndicatiorView.hidden = YES;
    };
    
    [self.imageView cancelImageRequestOperation];
    [self.imageView setImageWithURLRequest:request
                          placeholderImage:nil
                                   success:successBlock
                                   failure:failBlock];
}

- (void)loadDetailedImageFromURL:(NSString *)urlString
                      completion:(void (^)())completion
{
    if (_isGIF) {
        urlString = [urlString stringByReplacingOccurrencesOfString:@"jpg" withString:@"gif"];
        urlString = [urlString stringByReplacingOccurrencesOfString:@"large" withString:@"bmiddle"];
        NSURL *url = [NSURL URLWithString:urlString];
        
        if(_errorIndicateViewController) {
            [_errorIndicateViewController dismissViewAnimated:NO completion:nil];
            _errorIndicateViewController = [ErrorIndicatorViewController showErrorIndicatorWithType:ErrorIndicatorViewControllerTypeLoading contentText:nil animated:NO];
        }
        else {
            _errorIndicateViewController = [ErrorIndicatorViewController showErrorIndicatorWithType:ErrorIndicatorViewControllerTypeLoading contentText:nil animated:YES];
        }
        
        dispatch_queue_t downloadQueue = dispatch_queue_create("downloadQueue", NULL);
        
        dispatch_async(downloadQueue, ^{
                        
            NSData *imageData = [NSData dataWithContentsOfURL:url];
            UIImage *image = [UIImage animatedImageWithGIFData:imageData];
            
            __block __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (_imageViewMode != CastViewImageViewModeNormal) {
                    weakSelf.imageView.image = image;
                    
                    if (completion) {
                        completion();
                    }
                }
                
                [_errorIndicateViewController dismissViewAnimated:YES completion:^{
                    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
                }];
                _errorIndicateViewController = nil;
            });
            
        });
        
        dispatch_release(downloadQueue);
    } else {
        
        [self.imageView cancelImageRequestOperation];
        [self.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]
                              placeholderImage:self.imageView.image
                                       success:nil
                                       failure:nil];
    }
}

- (void)setUpPlayButtonWithURL:(NSString *)url type:(int)type
{
    if (url == nil) {
        return;
    }
    NSString *imageName = type == kActionButtonTypeMedia ? @"button_play.png" : @"button_vote.png";
    self.url = url;
    [self.actionButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    self.actionButton.hidden = NO;
    [self.actionButton fadeIn];
}

- (void)didClickActionButton
{
    [InnerBrowserViewController loadLongLinkWithURL:[NSURL URLWithString:self.url]];
}


- (void)clearCurrentImage
{
    self.imageView.image = nil;
}

- (void)setUpGifIcon:(NSString *)urlString
{
    _isGIF = [self checkGif:urlString];
    self.gifIcon.hidden = !_isGIF;
    if (_isGIF) {
        [self bringSubviewToFront:self.gifIcon];
        [self.gifIcon resetOrigin:CGPointMake(self.frame.size.width - 50, self.frame.size.height - 40)];
    }
}

- (BOOL)checkGif:(NSString*)url
{
    if (url == nil) {
        return NO;
    }
    
    NSString* extName = [url substringFromIndex:([url length] - 3)];
    return  [extName compare:@"gif"] == NSOrderedSame;
}

- (void)reset
{
    _url = @"";
    _isGIF = NO;
    _gifIcon.hidden = YES;
    _staticGIFImage = nil;
    _actionButton.hidden = YES;
    
    for (UIGestureRecognizer *gestureRecognizer in self.gestureRecognizers) {
        gestureRecognizer.enabled = NO;
    }
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (CGSize)targetSize
{
    return CGSizeMake(_initialSize.width +  _deltaWidth, _initialSize.height +  _deltaHeight);
}

- (UIImageView*)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.frame];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.backgroundColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1.0];
        [self addSubview:_imageView];
    }
    return _imageView;
}

-(UIImageView *)coverView
{
    if (!_coverView) {
        _coverView = [[UIImageView alloc] initWithFrame:CGRectMake(-5, -4, self.frame.size.width + 10.0, self.frame.size.height + 10.0)];
        self.coverView.image = [[UIImage imageNamed:@"card_image_edge.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(7.0, 8.0, 9.0, 8.0)];
        _coverView.contentMode = UIViewContentModeScaleToFill;
        _coverView.clipsToBounds = YES;
        [self insertSubview:_coverView aboveSubview:self.imageView];
    }
    return _coverView;
}

- (UIButton *)actionButton
{
    if (!_actionButton) {
        _actionButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 67.0, 67.0)];
        [_actionButton setImage:[UIImage imageNamed:@"button_play.png"] forState:UIControlStateNormal];
        [_actionButton addTarget:self action:@selector(didClickActionButton) forControlEvents:UIControlEventTouchUpInside];
        _actionButton.hidden = YES;
        [self insertSubview:_actionButton aboveSubview:self.coverView];
    }
    
    return _actionButton;
}

- (UIActivityIndicatorView *)activityIndicatiorView
{
    if (!_activityIndicatiorView) {
        _activityIndicatiorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self insertSubview:_activityIndicatiorView aboveSubview:self.imageView];
    }
    return _activityIndicatiorView;
}

- (UIImageView *)gifIcon
{
    if (!_gifIcon) {
        _gifIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kRLIconGif]];
        _gifIcon.contentMode = UIViewContentModeTop;
        _gifIcon.hidden = YES;
        [_gifIcon resetSize:CGSizeMake(32.0, 20.0)];
        [self addSubview:_gifIcon];
    }
    return _gifIcon;
}

@end
