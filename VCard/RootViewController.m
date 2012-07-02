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
    [self setUpNotifications];
    self.navigationController.navigationBarHidden = YES;
    [self.view addSubview:self.castViewController.view];
    [self.view addSubview:self.shelfViewController.view];
    self.shelfViewController.view.hidden = YES;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark - Setup Notifications
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
}

- (void)showGroup:(NSNotification *)notification
{
    self.shelfViewController.view.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        [self.castViewController.view resetOriginY:147.0];
        [self.shelfViewController.view resetOriginY:0.0];
    } completion:^(BOOL finished) {
    }];
}

- (void)hideGroup:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.castViewController.view resetOriginY:0.0];
        [self.shelfViewController.view resetOriginY:-147.0];
    } completion:^(BOOL finished) {
        self.shelfViewController.view.hidden = YES;
    }];
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
    [self.castViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.shelfViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameOrientationChanged object:nil];
    [self.castViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
//    [self.shelfViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

#pragma mark - Properties
- (CastViewController*)castViewController
{
    if (_castViewController == nil) {
        _castViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CastViewController"];
        _castViewController.currentUser = self.currentUser;
        _castViewController.view.frame = self.view.bounds;
        [_castViewController initialLoad];
    }
    return _castViewController;
}

- (ShelfViewController *)shelfViewController
{
    if (_shelfViewController == nil) {
        _shelfViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ShelfViewController"];
        _shelfViewController.currentUser = self.currentUser;
        _shelfViewController.view.frame = kShelfViewControllerFrame;
        [_shelfViewController.view resetWidth:self.view.bounds.size.width];
    }
    return _shelfViewController;
}

@end
