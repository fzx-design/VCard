//
//  EmptyIndicatorViewController.m
//  VCard
//
//  Created by Gabriel Yeah on 12-8-2.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "EmptyIndicatorViewController.h"

@interface EmptyIndicatorViewController ()

@end

@implementation EmptyIndicatorViewController

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

- (IBAction)didClickRefreshButton:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(didClickRefreshButton)]) {
        [self.delegate didClickRefreshButton];
    }
}

@end
