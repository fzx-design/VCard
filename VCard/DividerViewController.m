//
//  DividerViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-5-22.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "DividerViewController.h"
#import "NSDateAddition.h"
#import "ResourceList.h"

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
    self.view.autoresizingMask = UIViewAutoresizingNone;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetLayoutBeforeRotating)
                                                 name:kNotificationNameOrientationWillChange
                                               object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)updateTimeInformation:(NSDate *)date
{
    self.timeLabel.text = [date customString];
    
    [self resetLayout:YES];
}

- (void)resetLayoutBeforeRotating
{
    [self resetLayout:NO];
}

- (void)resetLayout:(BOOL)didRotate
{
    CGFloat timeStringWidth = ceilf([self.timeLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:12.0f] constrainedToSize:CGSizeMake(1000.0, 30.0) lineBreakMode:UILineBreakModeWordWrap].width) + 1;
    
    CGFloat screenWidth = [self currentScreenWidth:didRotate];
    
    [self view:self.timeLabel resetWidth:timeStringWidth];
    [self view:self.timeLabel resetOriginX:screenWidth / 2 - timeStringWidth / 2 + 4];
    [self view:self.leftPattern resetOriginX:screenWidth / 2 - timeStringWidth / 2 - 28];
    [self view:self.rightPattern resetOriginX:screenWidth / 2 + timeStringWidth / 2 + 3];
}

- (CGFloat)currentScreenWidth:(BOOL)didRotate
{
    BOOL isPortrait = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    
    isPortrait  = didRotate ? isPortrait : !isPortrait;
    
    return isPortrait ? 768.0 : 1024.0;
}

- (void)view:(UIView *)view resetOriginX:(CGFloat)originX
{
    CGRect frame = view.frame;
    frame.origin.x = originX;
    view.frame = frame;
}

- (void)view:(UIView *)view resetWidth:(CGFloat)width
{
    CGRect frame = view.frame;
    frame.size.width = width;
    view.frame = frame;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
