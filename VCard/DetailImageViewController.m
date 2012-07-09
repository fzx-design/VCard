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
    CGPoint origin = [_cardViewController.view convertPoint:_imageView.frame.origin toView:self.view];
    origin.y += 5.0;
    [_imageView resetOrigin:origin];
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
    self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    _topBarView.alpha = 0.0;
    _bottomBarView.alpha = 0.0;
}

- (void)enterDetailedImageViewMode
{
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.3f];

//    [_imageView.layer setAffineTransform:CGAffineTransformMakeScale(1.5, 1.5)];
//    CGRect frame = _imageView.layer.frame;
//    CGPoint targetPoint = frame.origin;
//    targetPoint.x = [UIApplication screenWidth] / 2 - frame.size.width / 2;
//    targetPoint.y = [UIApplication screenHeight] / 2 - frame.size.height / 2;
//    [_imageView.layer setAffineTransform:];
    
    CGAffineTransform transform = _imageView.layer.affineTransform;
    CGFloat angle = atan2(transform.b, transform.a);
    transform = CGAffineTransformRotate(transform, -angle);
    _imageView.layer.affineTransform = transform;
    
    CGRect frame = _imageView.frame;
    
    NSLog(@"original: %@", NSStringFromCGRect(_imageView.frame));
    
    CGFloat originX = frame.origin.x;
    CGFloat originY = frame.origin.y;
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    
    CGFloat screenWidth = [UIApplication screenWidth];
    CGFloat screenHeight = [UIApplication screenHeight];
    
    CGFloat deltaX = (screenWidth - 2 * originX - width) / 2;
    CGFloat deltaY = (screenHeight - 2 * originY - height) / 2;
    
    NSLog(@"%f, %f, %f, %f", originX, originY, width, height);
    NSLog(@"%f, %f", deltaX, deltaY);
    
    _imageView.layer.affineTransform = CGAffineTransformTranslate(_imageView.layer.affineTransform, deltaX, deltaY);
        
//    [UIView commitAnimations];
    
    NSLog(@"edited: %@", NSStringFromCGRect(_imageView.frame));
}

@end
