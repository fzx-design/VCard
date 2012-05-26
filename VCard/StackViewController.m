//
//  StackViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-5-26.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "StackViewController.h"

@interface StackViewController ()

@end

@implementation StackViewController

@synthesize stackView = _stackView;
@synthesize controllerStack = _controllerStack;

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
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)addViewController:(UIViewController *)viewController
{
    [self.stackView addNewPage:viewController.view];
    [self.controllerStack addObject:viewController];
}

- (StackView *)stackView
{
    if (!_stackView) {
        _stackView = [[StackView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_stackView];
    }
    return _stackView;
}

- (NSMutableArray *)controllerStack
{
    if (!_controllerStack) {
        _controllerStack = [[NSMutableArray alloc] init];
    }
    return _controllerStack;
}

@end
