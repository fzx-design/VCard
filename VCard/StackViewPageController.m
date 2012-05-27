//
//  StackViewPageController.m
//  VCard
//
//  Created by 海山 叶 on 12-5-26.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "StackViewPageController.h"

@interface StackViewPageController ()

@end

@implementation StackViewPageController

@synthesize pageIndex = _pageIndex;
@synthesize testButton;

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

- (IBAction)createNewStackPage:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameAddNewStackPage object:self];
}


@end
