//
//  UIApplication+Addition.m
//  VCard
//
//  Created by 紫川 王 on 12-5-26.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "UIApplication+Addition.h"
#import "AppDelegate.h"
#import <MobileCoreServices/MobileCoreServices.h>

static UIViewController *_modalViewController;
static UIView *_backView;

@interface UIApplication() 

@end

@implementation UIApplication (Addition)

+ (BOOL)isRetinaDisplayiPad
{
    return [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [UIScreen mainScreen].scale > 1;
}

+ (CGFloat)heightExcludingTopBar
{
    return UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? 704.0 : 960.0;
}

+ (CGFloat)screenWidth
{
    return UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? 1024.0 : 768.0;
}

+ (CGFloat)screenHeight
{
    return UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? 768.0 : 1004.0;
}

+ (UIInterfaceOrientation)currentOrientation
{
    return UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeLeft;
}

- (UIViewController *)rootViewController
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return (UIViewController *)appDelegate.window.rootViewController;
}

+ (void)presentModalViewController:(UIViewController *)vc animated:(BOOL)animated {
    [[UIApplication sharedApplication] presentModalViewController:vc animated:animated];
}

+ (void)dismissModalViewControllerAnimated:(BOOL)animated {
    [[UIApplication sharedApplication] dismissModalViewControllerAnimated:animated];
}

- (CGSize)screenSize {
    CGFloat screenWidth = 1024, screenHeight = 748;
    if(UIInterfaceOrientationIsPortrait(self.statusBarOrientation)) {
        screenWidth = 768;
        screenHeight = 1004;
    }
    return CGSizeMake(screenWidth, screenHeight);
}

- (void)presentModalViewController:(UIViewController *)vc animated:(BOOL)animated
{
    if (_modalViewController)
        return;
    	
    _modalViewController = vc;
	_backView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.screenSize.width, self.screenSize.height)];
	_backView.backgroundColor = [UIColor blackColor];
    _backView.alpha = 0;
    _backView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
	[self.rootViewController.view addSubview:_backView];
	[self.rootViewController.view addSubview:vc.view];
    
    if(animated) {
        CGRect frame = vc.view.frame;
        frame.origin.x = 0;
        frame.origin.y = self.screenSize.height;
        vc.view.frame = frame;
        
        [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            CGRect frame = vc.view.frame;
            frame.origin.y = 20;
            vc.view.frame = frame;
        } completion:nil];
    }
    else {
        CGRect frame = vc.view.frame;
        frame.origin.y = 20;
        vc.view.frame = frame;
    }
    
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _backView.alpha = 0.6f;
    } completion:nil];

}

- (void)dismissModalViewControllerAnimated:(BOOL)animated {
    if(animated) {
        [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            _backView.alpha = 0.0;
            CGRect frame = _modalViewController.view.frame;
            frame.origin.y = self.screenSize.height;
            _modalViewController.view.frame = frame;
        } completion:^(BOOL finished) {
            [_backView removeFromSuperview];
            _backView = nil;
            [_modalViewController.view removeFromSuperview];
            _modalViewController = nil;
        }];
    } else {
        [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            _backView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [_backView removeFromSuperview];
            _backView = nil;
            _modalViewController = nil;
        }];
    }
}

+ (UIPopoverController *)getAlbumImagePickerFromButton:(UIButton *)button delegate:(id)delegate {
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
    ipc.delegate = delegate;
    ipc.allowsEditing = NO;
    
    UIPopoverController *pc = [[UIPopoverController alloc] initWithContentViewController:ipc];
    //pc.contentViewController.view.autoresizingMask = !UIViewAutoresizingFlexibleTopMargin;
    pc.delegate = delegate;
    
    return pc;
}

+ (UIPopoverController *)showAlbumImagePickerFromButton:(UIButton *)button delegate:(id)delegate {
    UIPopoverController *pc = [UIApplication getAlbumImagePickerFromButton:button delegate:delegate];
    [pc presentPopoverFromRect:button.bounds inView:button
      permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    return pc;
}

@end
