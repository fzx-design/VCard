//
//  MultiInterfaceOrientationViewController.m
//  VCard
//
//  Created by 王 紫川 on 12-6-26.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "MultiInterfaceOrientationViewController.h"

@interface MultiInterfaceOrientationViewController ()

@end

@implementation MultiInterfaceOrientationViewController

@synthesize subViewControllers = _subViewControllers;
@synthesize currentInterfaceOrientation = _currentInterfaceOrientation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSString *nibName = nil;
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        nibName = [NSString stringWithFormat:@"%@-landscape", NSStringFromClass([self class])];
    } else {
        nibName = [NSString stringWithFormat:@"%@", NSStringFromClass([self class])];
    }
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
        self.subViewControllers = [NSMutableArray array];
        self.currentInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    }
    return self;
}

- (BOOL)isCurrentOrientationLandscape {
    return UIInterfaceOrientationIsLandscape(self.currentInterfaceOrientation);
}

- (void)loadViewControllerWithInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    self.currentInterfaceOrientation = interfaceOrientation;
    
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@-landscape", NSStringFromClass([self class])] owner:self options:nil];
        self.view.frame = CGRectMake(0, 0, 1024, 748);
    } else {
        [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@", NSStringFromClass([self class])] owner:self options:nil];
        self.view.frame = CGRectMake(0, 0, 768, 1004);
    }
    [self.subViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        MultiInterfaceOrientationViewController *vc = obj;
        if ([vc isKindOfClass:[MultiInterfaceOrientationViewController class]]) {
            [vc loadViewControllerWithInterfaceOrientation:interfaceOrientation];
        }
    }];
    [self viewDidLoad];
}

- (void)configureRootViewTransformWithInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
        self.view.transform = CGAffineTransformMakeRotation(-M_PI_2);
    else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
    else if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
        self.view.transform = CGAffineTransformMakeRotation(M_PI);
    else
        self.view.transform = CGAffineTransformMakeRotation(0);
}

- (void)loadRootViewControllerWithInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    [self loadViewControllerWithInterfaceOrientation:interfaceOrientation];
    [self configureRootViewTransformWithInterfaceOrientation:interfaceOrientation];
}

@end
