//
//  DetailImageViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-7-6.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "DetailImageViewController.h"
#import "UIView+Resize.h"
#import "UIApplication+Addition.h"
#import "User.h"
#import "NSDateAddition.h"

@interface DetailImageViewController () {
    BOOL _statusBarHidden;
    CGFloat _lastScale;
    CGPoint _lastPoint;
    UIPinchGestureRecognizer *_pinchGestureRecognizer;
}

@end

@implementation DetailImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [ThemeResourceProvider configBackButtonDark:_returnButton];
    _pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchEvent:)];
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapEvent:)];
    [_scrollView addGestureRecognizer:_pinchGestureRecognizer];
    [_scrollView addGestureRecognizer:_tapGestureRecognizer];
    _scrollView.delegate = self;
    _scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
    _scrollView.maximumZoomScale = 5.0;
    _scrollView.minimumZoomScale = 0.5;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)setUpWithCardViewController:(CardViewController *)cardViewController
{
    _imageView = cardViewController.statusImageView;
    _cardViewController = cardViewController;
    _cardViewController.delegate = self;
    _lastPoint = [_cardViewController.view convertPoint:_imageView.frame.origin toView:self.view];
    _lastPoint.y += 20.0;
    [_imageView resetOrigin:_lastPoint];
    Status *targetStatus = _cardViewController.status;
    [_authorAvatarImageView loadImageFromURL:targetStatus.author.profileImageURL completion:nil];
    [_authorAvatarImageView setVerifiedType:[targetStatus.author verifiedTypeOfUser]];
    _authorNameLabel.text = targetStatus.author.screenName;
    _timeStampLabel.text = [targetStatus.createdAt stringRepresentation];
    [self.scrollView addSubview:_imageView];
    
    if (cardViewController.imageViewMode == CastViewImageViewModeDetailed) {
        [self enterDetailedImageViewMode];
    }
}

#pragma mark - IBAction
- (IBAction)didClickReturnButton:(id)sender
{
    [_cardViewController returnToInitialImageView];
}

#pragma mark - CardViewControllerDelegate
- (void)didChangeImageScale:(CGFloat)scale
{
    CGFloat alpha = scale - 1.0;
    alpha /= 0.5;
    if (alpha < 0.0) {
        alpha = 0.0;
    } else {
        alpha = alpha;
    }
    _topBarView.alpha =alpha;
    _bottomBarView.alpha = alpha;
    self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:alpha];
}

- (void)didReturnImageView
{
    self.view.hidden = YES;
    self.view.userInteractionEnabled = NO;
    _cardViewController.delegate = nil;
    _cardViewController = nil;
}

- (void)willReturnImageView
{
    [_imageView resetOrigin:_lastPoint];
    self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    _topBarView.alpha = 0.0;
    _bottomBarView.alpha = 0.0;
}

- (void)enterDetailedImageViewMode
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    
    _statusBarHidden = NO;
    _imageView.userInteractionEnabled = NO;
    _topBarView.alpha = 1.0;
    _bottomBarView.alpha = 1.0;
    self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    
    CGFloat scale = sqrt(_imageView.transform.a * _imageView.transform.a + _imageView.transform.c * _imageView.transform.c);
    CGFloat targetScale = [UIApplication isCurrentOrientationLandscape] ? _imageView.targetHorizontalScale : _imageView.targetVerticalScale;
    
    [_imageView pinchResizeToScale:1.5];
        
    scale = targetScale / scale;
    
    CGAffineTransform transform = _imageView.transform;
    CGFloat angle = atan2(transform.b, transform.a);
    transform = CGAffineTransformRotate(transform, -angle);
    _imageView.transform = transform;
    _imageView.transform = CGAffineTransformScale(_imageView.transform, scale, scale);
    
    CGFloat screenWidth = [UIApplication screenWidth];
    CGFloat screenHeight = [UIApplication screenHeight];
    
    CGFloat a = _imageView.transform.a;
    CGFloat b = _imageView.transform.b;
    CGFloat c = _imageView.transform.c;
    CGFloat d = _imageView.transform.d;
    
    CGFloat scaleX = sqrt(a * a + c * c);
    CGFloat scaleY = sqrt(b * b + d * d);
    
    CGFloat width = [_imageView targetSize].width * scaleX;
    CGFloat height = [_imageView targetSize].height * scaleY;
    
    [_imageView resetOrigin:CGPointMake(screenWidth / 2 - width / 2, screenHeight / 2 - height / 2)];
    
    [UIView commitAnimations];
    
    Status *targetStatus = self.cardViewController.status;
    if (self.cardViewController.isReposted) {
        targetStatus = targetStatus.repostStatus;
    }
    [_imageView loadDetailedImageFromURL:targetStatus.originalPicURL completion:nil];
}

#pragma mark - Handle Gesture Events
- (void)handlePinchEvent:(UIPinchGestureRecognizer *)sender
{
    
}

- (void)handleTapEvent:(UITapGestureRecognizer *)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        CGFloat alpha = _statusBarHidden ? 1.0 : 0.0;
        _topBarView.alpha = alpha;
        _bottomBarView.alpha = alpha;
    } completion:^(BOOL finished) {
        _statusBarHidden = !_statusBarHidden;
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:!_statusBarHidden withAnimation:UIStatusBarAnimationFade];
}

#pragma mark - ScrollView Delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
    
//    self.imageView.frame = frame;
//    self.scrollView.contentSize = size;
}

@end
