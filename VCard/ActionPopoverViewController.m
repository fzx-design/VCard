//
//  ActionPopoverViewController.m
//  EnterTheMatrix
//
//  Created by Mark Pospesel on 3/8/12.
//  Copyright (c) 2012 Mark Pospesel. All rights reserved.
//

#import "ActionPopoverViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+Resize.h"
#import "UIApplication+Addition.h"

#define CARD_WIDTH  362.

@interface ActionPopoverViewController ()

@property (readonly) CGFloat centerBarHeight;

@end

@implementation ActionPopoverViewController

@synthesize contentView = _contentView;
@synthesize topBar = _topBar;
@synthesize centerBar = _centerBar;
@synthesize bottomBar = _bottomBar;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	tapGesture.delegate = self;
	[self.view addGestureRecognizer:tapGesture];
	
	UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
	pinchGesture.delegate = self;
	[self.contentView addGestureRecognizer:pinchGesture];
}

- (void)viewDidUnload
{
    self.contentView = nil;
    self.topBar = nil;
    self.centerBar = nil;
    self.bottomBar = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Properties

- (CGFloat)centerBarHeight {
    return self.centerBar.frame.size.height;
}

#pragma mark - Gesture recognizer

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer {
    [self.delegate actionPopoverViewDidDismiss];
}

- (void)handlePinch:(UIPinchGestureRecognizer *)gestureRecognizer {
    //UIGestureRecognizerState state = [gestureRecognizer state];
}

#pragma mark - Crop view methods

- (void)configureCropImageView:(UIView *)cropView cropPosY:(CGFloat)y {
    UIGraphicsBeginImageContext(cropView.bounds.size);
    [cropView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSLog(@"cropView Frame:%@", NSStringFromCGRect(cropView.frame));

    CGRect topRect = CGRectMake(0, 0, cropView.frame.size.width, y);
    CGRect bottomRect = CGRectMake(0, y, cropView.frame.size.width, cropView.frame.size.height - y);
    UIImage *topImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(viewImage.CGImage, topRect)];
    UIImage *bottomImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(viewImage.CGImage, bottomRect)];
    
    self.topBar.image = topImage;
    self.bottomBar.image = bottomImage;
    
    [self.topBar resetSize:topImage.size];
    [self.bottomBar resetSize:bottomImage.size];
}

- (void)setCropView:(UIView *)view cropPosY:(CGFloat)y {
    [self configureCropImageView:view cropPosY:y];
    [self.contentView resetSize:view.frame.size];
    [self.topBar resetOrigin:CGPointMake(0, 0)];
    [self.centerBar resetOrigin:CGPointMake(0, y)];
    [self.topBar resetOrigin:CGPointMake(0, y + self.centerBar.frame.size.height)];
}

@end
