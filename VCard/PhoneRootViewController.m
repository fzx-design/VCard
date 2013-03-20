//
//  PhoneRootViewController.m
//  VCard
//
//  Created by Emerson on 13-3-19.
//  Copyright (c) 2013年 Mondev. All rights reserved.
//

#import "PhoneRootViewController.h"
#import "NSNotificationCenter+Addition.h"
#import "UIApplication+Addition.h"

@interface PhoneRootViewController ()

@end

@implementation PhoneRootViewController

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
    self.simpletableviewcontroller = [[SimpleTableViewController alloc] initWithNibName:@"SimpleTableViewController" bundle:nil];
    [self.view insertSubview:self.simpletableviewcontroller.view belowSubview:self.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
