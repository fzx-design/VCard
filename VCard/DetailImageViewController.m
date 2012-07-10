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
	// Do any additional setup after loading the view.
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
    _lastPoint.y += 5.0;
    [_imageView resetOrigin:_lastPoint];
    Status *targetStatus = _cardViewController.status;
    [_authorAvatarImageView loadImageFromURL:targetStatus.author.profileImageURL completion:nil];
    [_authorAvatarImageView setVerifiedType:[targetStatus.author verifiedTypeOfUser]];
    _authorNameLabel.text = targetStatus.author.screenName;
    _timeStampLabel.text = [targetStatus.createdAt stringRepresentation];
    [self.scrollView addSubview:_imageView];
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

- (void)enterDetailedImageViewMode:(CGFloat)currentScale
{
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.3f];
//    
//    NSLog(@"original: %@", NSStringFromCGRect(_imageView.frame));
//    
//    _topBarView.alpha = 1.0;
//    _bottomBarView.alpha = 1.0;
//    self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
//    
//    CGFloat scale = sqrt(_imageView.layer.affineTransform.a * _imageView.layer.affineTransform.a + _imageView.layer.affineTransform.c * _imageView.layer.affineTransform.c);
//    CGFloat targetScale = _imageView.targetScale;
//    
//    [_imageView pinchResizeToScale:1.5];
//    
//    if (scale > targetScale) {
//        scale = targetScale;
//    }
//    scale = 1.0 - (scale - targetScale);
//    
//    CGAffineTransform transform = _imageView.layer.affineTransform;
//    CGFloat angle = atan2(transform.b, transform.a);
//    transform = CGAffineTransformRotate(transform, -angle);
//    _imageView.layer.affineTransform = transform;
//    _imageView.layer.affineTransform = CGAffineTransformScale(_imageView.layer.affineTransform, scale, scale);
//    
//    CGFloat screenWidth = [UIApplication screenWidth];
//    CGFloat screenHeight = [UIApplication screenHeight];
//    
//    NSLog(@"before edit: %@", NSStringFromCGRect(_imageView.frame));
//    
//    CGFloat a = _imageView.layer.affineTransform.a;
//    CGFloat b = _imageView.layer.affineTransform.b;
//    CGFloat c = _imageView.layer.affineTransform.c;
//    CGFloat d = _imageView.layer.affineTransform.d;
//    
//    CGFloat scaleX = sqrt(a * a + c * c);
//    CGFloat scaleY = sqrt(b * b + d * d);
//    
//    CGFloat width = [_imageView targetSize].width * scaleX;
//    CGFloat height = [_imageView targetSize].height * scaleY;
//    
//    [_imageView resetOrigin:CGPointMake(screenWidth / 2 - width / 2, screenHeight / 2 - height / 2)];
//    
//    [UIView commitAnimations];
//    
//    NSLog(@"center: %@", NSStringFromCGPoint(_imageView.center));
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3f];
    
    _topBarView.alpha = 1.0;
    _bottomBarView.alpha = 1.0;
    self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    
    CGFloat scale = sqrt(_imageView.transform.a * _imageView.transform.a + _imageView.transform.c * _imageView.transform.c);
    CGFloat targetScale = _imageView.targetScale;
    
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
}

@end
