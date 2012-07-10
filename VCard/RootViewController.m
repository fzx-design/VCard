//
//  RootViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-4-18.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "RootViewController.h"
#import "WBClient.h"
#import "ResourceList.h"
#import "Group.h"
#import "NewLoginViewController.h"
#import "NSNotificationCenter+Addition.h"
#import "UIApplication+Addition.h"

#define kShelfViewControllerFrame CGRectMake(0.0, -147.0, 768.0, 147.0);

@interface RootViewController ()

@end

@implementation RootViewController

@synthesize castViewController = _castViewController;

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
<<<<<<< HEAD
    
    if(self.currentUser) {
=======
    self.navigationController.navigationBarHidden = YES;
    if (self.currentUser == nil) {
        [[[NewLoginViewController alloc] init] show];
    } else {
>>>>>>> 修复status bar隐藏后会有纹理的问题，原因是navigation bar应该show。。
        [self setUpNotifications];
        [self setUpViews];
    }
    
    [NSNotificationCenter registerChangeCurrentUserNotificationWithSelector:@selector(handleChangeCurrentUserNotification:) target:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.currentUser == nil) {
        [[[NewLoginViewController alloc] init] show];
    }
}

#pragma mark - Handle notifications
- (void)handleChangeCurrentUserNotification:(NSNotification *)notification {
    [self setUpNotifications];
    [self setUpViews];
}

#pragma mark - Setup Notifications
- (void)setUpViews
{
    [self.view resetOrigin:CGPointZero];
    [self.view resetSize:CGSizeMake([UIApplication screenWidth], [UIApplication screenHeight])];
    [self.view addSubview:self.castViewController.view];
    [self.view addSubview:self.shelfViewController.view];
    self.shelfViewController.view.hidden = YES;
}

- (void)setUpNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(showGroup:)
                   name:kNotificationNameShouldShowGroup
                 object:nil];
    [center addObserver:self
               selector:@selector(hideGroup:)
                   name:kNotificationNameShouldHideGroup
                 object:nil];
    [center addObserver:self
               selector:@selector(showDetailImageView:)
                   name:kNotificationNameShouldShowDetailImageView
                 object:nil];
    [center addObserver:self
               selector:@selector(hideDetailImageView:)
                   name:kNotificationNameShouldHideDetailImageView
                 object:nil];
}

#pragma mark - Notifications
#pragma mark Shelf View Controller Notifications
- (void)showGroup:(NSNotification *)notification
{
    self.shelfViewController.view.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        [_castViewController.view resetOriginY:150.0];
        [_shelfViewController.view resetOriginY:0.0];
    } completion:^(BOOL finished) {
    }];
}

- (void)hideGroup:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        [_castViewController.view resetOriginY:0.0];
        [_shelfViewController.view resetOriginY:-150.0];
    } completion:^(BOOL finished) {
        _shelfViewController.view.hidden = YES;
    }];
}

#pragma mark Detail Image View Controller Notifications
- (void)showDetailImageView:(NSNotification *)notification
{
    NSDictionary *dict = notification.object;
    //    UIImageView *imageView = [dict objectForKey:kNotificationObjectKeyImageView];
    CardViewController *vc = [dict objectForKey:kNotificationObjectKeyStatus];
    //    vc.delegate = self.detailImageViewController;
    self.detailImageViewController.view.hidden = NO;
    self.detailImageViewController.view.userInteractionEnabled = YES;
    [self.detailImageViewController setUpWithCardViewController:vc];
}

- (void)hideDetialImageView:(NSNotification *)notification
{
    self.detailImageViewController.view.hidden = YES;
    self.detailImageViewController.view.userInteractionEnabled = NO;
}

#pragma mark - Handle Rotations
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    NSString *orientation = UIInterfaceOrientationIsPortrait(toInterfaceOrientation) ? kOrientationPortrait : kOrientationLandscape;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameOrientationWillChange object:orientation];
    
    [_castViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [_shelfViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameOrientationChanged object:nil];
    [_castViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [_shelfViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark - Properties
- (CastViewController*)castViewController
{
    if (_castViewController == nil) {
        _castViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CastViewController"];
        [_castViewController.view resetSize:self.view.frame.size];
        [_castViewController.view resetOrigin:CGPointZero];
    }
    return _castViewController;
}

- (ShelfViewController *)shelfViewController
{
    if (_shelfViewController == nil) {
        _shelfViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ShelfViewController"];
        _shelfViewController.view.frame = kShelfViewControllerFrame;
        [_shelfViewController.view resetWidth:self.view.bounds.size.width];
    }
    return _shelfViewController;
}

#pragma mark - Detail Image View Controller
- (DetailImageViewController *)detailImageViewController
{
    if (!_detailImageViewController) {
        _detailImageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailImageViewController"];
        _detailImageViewController.view.frame = self.view.bounds;
        [self.view addSubview:_detailImageViewController.view];
    }
    return _detailImageViewController;
}

@end
