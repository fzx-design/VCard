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
#import "UIScrollView+ZoomToPoint.h"

@interface DetailImageViewController () {
    BOOL _statusBarHidden;
    BOOL _firstZoom;
    BOOL _secondZoom;
    CGFloat _lastScale;
    CGPoint _initialPoint;
    CGFloat _currentScale;
    CGPoint _touchCenter;
    CGFloat _originScale;
    
    UIRotationGestureRecognizer *_rotationGestureRecognizer;
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
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapEvent:)];
    [_scrollView addGestureRecognizer:_tapGestureRecognizer];
    _scrollView.delegate = self;
    _scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
    _scrollView.maximumZoomScale = 5.0;
    _scrollView.minimumZoomScale = 0.5;
    _rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotationGesture:)];
    _rotationGestureRecognizer.delegate = self;
    [_scrollView addGestureRecognizer:_rotationGestureRecognizer];
    
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
    _initialPoint = [_cardViewController.view convertPoint:_imageView.frame.origin toView:self.view];
    _initialPoint.y += 20.0;
    [_imageView resetOrigin:_initialPoint];
    Status *targetStatus = _cardViewController.status;
    [_authorAvatarImageView loadImageFromURL:targetStatus.author.profileImageURL completion:nil];
    [_authorAvatarImageView setVerifiedType:[targetStatus.author verifiedTypeOfUser]];
    _authorNameLabel.text = targetStatus.author.screenName;
    _timeStampLabel.text = [targetStatus.createdAt stringRepresentation];
    [self.scrollView addSubview:_imageView];
    
    if (cardViewController.imageViewMode == CastViewImageViewModeDetailedNormal) {
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
    CGFloat offset = scale;
    if (self.cardViewController.imageViewMode == CastViewImageViewModePinchingOut) {
        offset = [_imageView scaleOffset];
        offset = offset > 0.5 ? 0.5 : offset;
    } else {
        offset = offset < -0.5 ? 0.0 : 0.5 + offset;
    }
    CGFloat alpha = offset /= 0.5;
    if (alpha < 0.0) {
        alpha = 0.0;
    } else {
        alpha = alpha;
    }
    _topBarView.alpha = alpha;
    _bottomBarView.alpha = alpha;
    self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:alpha];
}

- (void)didReturnImageView
{
    self.view.hidden = YES;
    self.view.userInteractionEnabled = NO;
    _cardViewController.delegate = nil;
    _cardViewController = nil;
    _imageView = nil;
    _scrollView.zoomScale = 1.0;
}

- (void)willReturnImageView
{
    [_imageView resetOrigin:_initialPoint];
    [self setBackgroundAlphaTo:0.0];
    [self recoverScrollViewRotation];
}

- (void)enterDetailedImageViewMode
{
    _cardViewController.imageViewMode = CastViewImageViewModeDetailedNormal;
    _imageView.userInteractionEnabled = NO;
    _statusBarHidden = NO;
    _currentScale = 1.0;
    
    [UIView animateWithDuration:0.3 animations:^{
        [self setBackgroundAlphaTo:1.0];
        [self initDetialedImageViewTransform];
        [self initScrollView];
    }];
    
    [self performSelector:@selector(resetImageViewSize) withObject:nil afterDelay:0.3];
    [self loadDetailedImage];
}

- (void)initDetialedImageViewTransform
{
    [_imageView pinchResizeToScale:1.5];
    
    CGFloat targetScale = [UIApplication isCurrentOrientationLandscape] ? _imageView.targetHorizontalScale : _imageView.targetVerticalScale;
    
    CGAffineTransform transform = _imageView.transform;
    CGFloat angle = atan2(transform.b, transform.a);
    transform = CGAffineTransformRotate(transform, -angle);
    
    CGFloat scale = sqrt(transform.a * transform.a + transform.c * transform.c);
    scale = targetScale / scale;
    transform = CGAffineTransformScale(transform, scale, scale);
    
    _imageView.transform = transform;
    
    CGFloat screenWidth = [UIApplication screenWidth];
    CGFloat screenHeight = [UIApplication screenHeight];
    
    CGFloat width = [_imageView targetSize].width * targetScale;
    CGFloat height = [_imageView targetSize].height * targetScale;
    
    [_imageView resetOrigin:CGPointMake(screenWidth / 2 - width / 2, screenHeight / 2 - height / 2)];
}

- (void)initScrollView
{
    _scrollView.contentSize = CGSizeMake([UIApplication screenWidth], [UIApplication screenHeight]);
    _originScale = _scrollView.zoomScale;
    _scrollView.minimumZoomScale = _originScale;
    _scrollView.maximumZoomScale = _originScale * 5.0;
}

- (void)setBackgroundAlphaTo:(CGFloat)alpha
{
    _topBarView.alpha = alpha;
    _bottomBarView.alpha = alpha;
    self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:alpha];
}

- (void)resetImageViewSize
{
    CGFloat targetScale = [UIApplication isCurrentOrientationLandscape] ? _imageView.targetHorizontalScale : _imageView.targetVerticalScale;
    CGFloat width = [_imageView targetSize].width * targetScale;
    CGFloat height = [_imageView targetSize].height * targetScale;
    [_imageView resetSize:CGSizeMake(width, height)];
}

- (void)loadDetailedImage
{
    Status *targetStatus = self.cardViewController.status;
    if (self.cardViewController.isReposted) {
        targetStatus = targetStatus.repostStatus;
    }
    [_imageView loadDetailedImageFromURL:targetStatus.originalPicURL completion:nil];
}

- (void)imageViewTapped
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGFloat targetScale = UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? _imageView.targetHorizontalScale : _imageView.targetVerticalScale;
    
    CGAffineTransform transform = _imageView.transform;
    CGFloat scale = sqrt(transform.a * transform.a + transform.c * transform.c);
    scale = targetScale / scale;
    transform = CGAffineTransformScale(transform, scale, scale);
    
    _imageView.transform = transform;
    
    CGFloat screenHeight = [UIApplication screenWidth];
    CGFloat screenWidth = [UIApplication screenHeight];
    
    CGFloat width = [_imageView targetSize].width * targetScale;
    CGFloat height = [_imageView targetSize].height * targetScale;
    
    [_imageView resetOrigin:CGPointMake(screenWidth / 2 - width / 2, screenHeight / 2 - height / 2)];
    
    scale = _scrollView.zoomScale / _originScale;
    
    _scrollView.contentSize = CGSizeMake(width, height);
    _originScale = _scrollView.zoomScale;
    _scrollView.minimumZoomScale = _originScale;
    _scrollView.maximumZoomScale = _originScale * 5.0;
    
    scale *= _originScale;
    
    [_imageView resetSize:CGSizeMake(width, height)];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (_statusBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    
    NSLog(@"contentOffset %@", NSStringFromCGPoint(_scrollView.contentOffset));
}

//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
//{
//    CGFloat screenWidth = [UIApplication screenWidth];
//    CGFloat screenHeight = [UIApplication screenHeight];
//    
//    if (_scrollView.zoomScale == _originScale) {
//        CGFloat scaleFactor = _scrollView.contentSize.width > _scrollView.contentSize.height ? screenWidth / screenHeight : screenHeight / screenWidth;
//        
//        CGFloat currentScale = _scrollView.zoomScale * scaleFactor;
//        
//        NSLog(@"before %f, after %f", _scrollView.zoomScale, currentScale);
//        [_scrollView setZoomScale:currentScale animated:YES];
//        _scrollView.maximumZoomScale = currentScale * 5;
//        _scrollView.minimumZoomScale = currentScale;
//        _originScale = currentScale;
//        
//        _scrollView.contentSize = CGSizeMake(screenWidth, screenHeight);
//    }
//}

#pragma mark - Handle Gesture Events
#pragma mark ScrollView Gesture
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer.view != otherGestureRecognizer.view)
        return NO;
    
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] || [otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
        return NO;
    
    return YES;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if (_firstZoom && _scrollView.zoomScale != _originScale) {
        _firstZoom = NO;
        if (_scrollView.zoomScale > _originScale) {
            _cardViewController.imageViewMode = CastViewImageViewModeDetailedZooming;
        } else {
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
            _cardViewController.imageViewMode = CastViewImageViewModePinchingIn;
            _scrollView.minimumZoomScale = 0.0;
        }
    }
    
    CGSize boundsSize = _scrollView.bounds.size;
    CGRect contentsFrame = _imageView.frame;
    
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
    
    _imageView.frame = contentsFrame;
    
    if (_cardViewController.imageViewMode == CastViewImageViewModePinchingIn) {
        [self didChangeImageScale:_scrollView.zoomScale - _originScale];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    _firstZoom = YES;
    if (_cardViewController.imageViewMode == CastViewImageViewModePinchingIn) {
        if (_scrollView.pinchGestureRecognizer.velocity > 2.0 || _scrollView.zoomScale < _originScale - 0.1) {
            [_cardViewController returnToInitialImageView];
        } else {
            [self recoverScrollViewRotation];
            _scrollView.minimumZoomScale = _originScale;
            [_scrollView setZoomScale:_originScale animated:YES];
            _cardViewController.imageViewMode = CastViewImageViewModeDetailedNormal;
        }
    } else if (_cardViewController.imageViewMode == CastViewImageViewModeDetailedZooming) {
        if (_scrollView.zoomScale < _scrollView.minimumZoomScale) {
            _cardViewController.imageViewMode = CastViewImageViewModeDetailedNormal;
        }
    }
}

- (void)recoverScrollViewRotation
{
    [UIView animateWithDuration:0.3 animations:^{
        CGAffineTransform transform = _scrollView.transform;
        CGFloat angle = atan2(transform.b, transform.a);
        _scrollView.transform = CGAffineTransformRotate(transform, -angle);
    }];
}

- (void)handleRotationGesture:(UIRotationGestureRecognizer *)sender
{
    if (_imageView && _cardViewController.imageViewMode == CastViewImageViewModePinchingIn) {
        [_cardViewController handleRotationGesture:sender];
    }
}

@end
