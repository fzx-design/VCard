//
//  DividerViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-5-22.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "DividerViewController.h"

@interface DividerViewController ()

@end

@implementation DividerViewController

@synthesize leftPattern = _leftPattern;
@synthesize rightPattern = _rightPattern;
@synthesize timeLabel = _timeLabel;

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

- (void)updateTimeInformation:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *dateString = [formatter stringFromDate:date];
    self.timeLabel.text = dateString;
}

@end
