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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSString *nibName = nil;
    if(UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        nibName = [NSString stringWithFormat:@"%@-landscape", NSStringFromClass([self class])];
    } else {
        nibName = [NSString stringWithFormat:@"%@", NSStringFromClass([self class])];
    }
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
        self.subViewControllers = [NSMutableArray array];
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)loadSubViewControllerInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if(UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@-landscape", NSStringFromClass([self class])] owner:self options:nil];
    } else {
        [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@", NSStringFromClass([self class])] owner:self options:nil];
    }
    [self viewDidLoad];
}

- (void)loadInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if(UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@-landscape", NSStringFromClass([self class])] owner:self options:nil];
        if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
            self.view.transform = CGAffineTransformMakeRotation(M_PI * 3 / 2);
        else
            self.view.transform = CGAffineTransformMakeRotation(M_PI / 2);
    } else {
        [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@", NSStringFromClass([self class])] owner:self options:nil];
        if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
            self.view.transform = CGAffineTransformMakeRotation(M_PI);
    }
    
    [self.subViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        MultiInterfaceOrientationViewController *vc = obj;
        if([vc isKindOfClass:[MultiInterfaceOrientationViewController class]]) {
            [vc loadSubViewControllerInterfaceOrientation:interfaceOrientation];
        }
    }];
    
    [self viewDidLoad];
}

@end
