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
    BOOL _shouldUseScrollViewZooming;
    CGFloat _lastScale;
    CGPoint _lastPoint;
    CGRect _contentFrame;
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
    self.cardViewController.imageViewMode = CastViewImageViewModeDetailedNormal;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    
    _statusBarHidden = NO;
    _shouldUseScrollViewZooming = YES;
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
    
    _scrollView.contentSize = CGSizeMake([UIApplication screenWidth], [UIApplication screenHeight]);
    _contentFrame = CGRectMake(_imageView.frame.origin.x, _imageView.frame.origin.y, width, height);
    
    [_imageView resetOrigin:CGPointMake(screenWidth / 2 - width / 2, screenHeight / 2 - height / 2)];
    
    [UIView commitAnimations];
    
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

#pragma mark - Handle Gesture Events
#pragma mark - ScrollView Gesture
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

@end
