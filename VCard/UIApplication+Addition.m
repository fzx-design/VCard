//
//  UIApplication+Addition.m
//  VCard
//
//  Created by 紫川 王 on 12-5-26.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "UIApplication+Addition.h"
#import "NSNotificationCenter+Addition.h"
#import "AppDelegate.h"
#import "ErrorIndicatorViewController.h"

#define MODAL_BACK_VIEW_MAX_ALPHA               (0.6f)

static NSMutableArray *_modalViewControllerStack = nil;
static NSMutableArray *_backViewStack = nil;

@interface UIApplication()

@property (nonatomic, readonly) NSMutableArray *modalViewControllerStack;
@property (nonatomic, readonly) NSMutableArray *backViewStack;
@property (nonatomic, readonly) UIView *topBackView;

@end

@implementation UIApplication (Addition)

#pragma mark - Notification handlers

- (void)rootViewControllerViewDidLoad:(NSNotification *)notification {
    NSLog(@"UIApplication+Addition : Reiceive RootViewControllerViewDidLoad Notification");
    UIView *rootView = self.rootViewController.view;
    for(int i = 0; i < self.modalViewControllerStack.count; i++) {
        UIViewController *vc = [self.modalViewControllerStack objectAtIndex:i];
        UIView *backView = [self.backViewStack objectAtIndex:i];
        
        [vc.view removeFromSuperview];
        [backView removeFromSuperview];
        
        [rootView addSubview:backView];
        [rootView addSubview:vc.view];
    }
}

#pragma mark - ModalViewController methods

- (NSMutableArray *)modalViewControllerStack {
    if(_modalViewControllerStack == nil) {
        _modalViewControllerStack = [NSMutableArray array];
    }
    return _modalViewControllerStack;
}

- (NSMutableArray *)backViewStack {
    if(_backViewStack == nil) {
        _backViewStack = [NSMutableArray array];
    }
    return _backViewStack;
}

+ (UIView *)createBackView {
    UIView *result = nil;
    result = [[UIView alloc] initWithFrame:CGRectMake(0, 20, [UIApplication screenWidth], [UIApplication screenHeight])];
    result.backgroundColor = [UIColor blackColor];
    result.alpha = 0;
    result.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    return result;
}

- (UIView *)topBackView {
    return self.backViewStack.lastObject;
}

- (UIViewController *)topModalViewController {
    return self.modalViewControllerStack.lastObject;
}

+ (void)presentModalViewController:(UIViewController *)vc animated:(BOOL)animated {
    [[UIApplication sharedApplication] presentModalViewController:vc animated:animated duration:MODAL_APPEAR_ANIMATION_DEFAULT_DURATION];
}

+ (void)dismissModalViewControllerAnimated:(BOOL)animated {    
    UIApplication *application = [UIApplication sharedApplication];
    [application dismissModalViewController:application.topModalViewController animated:animated duration:MODAL_APPEAR_ANIMATION_DEFAULT_DURATION];
}

+ (void)presentModalViewController:(UIViewController *)vc animated:(BOOL)animated duration:(NSTimeInterval)duration {
    [[UIApplication sharedApplication] presentModalViewController:vc animated:animated duration:duration];
}

+ (void)dismissModalViewControllerAnimated:(BOOL)animated duration:(NSTimeInterval)duration {
    UIApplication *application = [UIApplication sharedApplication];
    [application dismissModalViewController:application.topModalViewController animated:animated duration:duration];
}

+ (void)dismissModalViewController:(UIViewController *)vc animated:(BOOL)animated duration:(NSTimeInterval)duration {
    [[UIApplication sharedApplication] dismissModalViewController:vc animated:animated duration:duration];
}

- (void)presentModalViewController:(UIViewController *)vc animated:(BOOL)animated duration:(NSTimeInterval)duration {
    if([self.modalViewControllerStack containsObject:vc])
        return;
    
    __block BOOL existModalClass = NO;
    [self.modalViewControllerStack enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIViewController *vcInStack = obj;
        if([vcInStack class] == [vc class]) {
            existModalClass = YES;
            *stop = YES;
        }
    }];
    if(existModalClass)
        return;
    
    UIView *oldBackView = self.topBackView;
    UIView *newBackView = [UIApplication createBackView];
    [self.backViewStack addObject:newBackView];
    [self.rootViewController.view addSubview:newBackView];
    
    [self.modalViewControllerStack addObject:vc];
    [self.rootViewController.view addSubview:vc.view];
    
    if(animated) {
        CGRect frame = vc.view.frame;
        frame.origin.x = 0;
        frame.origin.y = self.screenSize.height;
        vc.view.frame = frame;
        
        [UIView animateWithDuration:duration animations:^{
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
    
    [UIView animateWithDuration:duration animations:^{
        oldBackView.alpha = 0;
        newBackView.alpha = MODAL_BACK_VIEW_MAX_ALPHA;
    } completion:nil];
}

- (void)dismissModalViewController:(UIViewController *)vc animated:(BOOL)animated duration:(NSTimeInterval)duration {
    if(self.modalViewControllerStack.count == 0)
        return;
    
    if(![self.modalViewControllerStack containsObject:vc])
        return;
    
    NSUInteger index = [self.modalViewControllerStack indexOfObject:vc];
        
    if(animated) {
        [UIView animateWithDuration:duration animations:^{
            CGRect frame = vc.view.frame;
            frame.origin.y = self.screenSize.height;
            vc.view.frame = frame;
        } completion:nil];
    }
    
    UIView *backViewToRemove = [self.backViewStack objectAtIndex:index];;
    [self.backViewStack removeObject:backViewToRemove];
    UIView *backViewToAppear = self.topBackView;
    
    [UIView animateWithDuration:duration animations:^{
        backViewToAppear.alpha = MODAL_BACK_VIEW_MAX_ALPHA;
        backViewToRemove.alpha = 0;
    } completion:^(BOOL finished) {
        [vc.view removeFromSuperview];
        [backViewToRemove removeFromSuperview];
        [self.modalViewControllerStack removeObject:vc];
        
        NSLog(@"UIApplication+Addition : back view stack count:%d", self.backViewStack.count);
        NSLog(@"UIApplication+Addition : modal view controller stack count:%d", self.modalViewControllerStack.count);
    }];
}

#pragma mark - Common methods

- (CGSize)screenSize {
    CGFloat screenWidth = 1024, screenHeight = 748;
    if(UIInterfaceOrientationIsPortrait(self.statusBarOrientation)) {
        screenWidth = 768;
        screenHeight = 1004;
    }
    return CGSizeMake(screenWidth, screenHeight);
}

+ (BOOL)isRetinaDisplayiPad
{
    return [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [UIScreen mainScreen].scale > 1;
}

+ (BOOL)isFirstGenerationiPad
{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad &&
            ![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]);
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
    return UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? 768.0 : 1024.0;
}

+ (BOOL)isCurrentOrientationLandscape
{
    return UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
}

+ (UIInterfaceOrientation)currentOppositeInterface
{
    return [UIApplication isCurrentOrientationLandscape] ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeLeft;
}

+ (UIInterfaceOrientation)currentInterface
{
    return [UIApplication sharedApplication].statusBarOrientation;
}

+ (void)relayoutRootViewController
{
    [[UIApplication sharedApplication].rootViewController willRotateToInterfaceOrientation:[UIApplication currentInterface] duration:0.0];
    [[UIApplication sharedApplication].rootViewController didRotateFromInterfaceOrientation:[UIApplication currentOppositeInterface]];
}

- (UIViewController *)rootViewController
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return (UIViewController *)appDelegate.window.rootViewController;
}

#pragma mark - Album methods

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
