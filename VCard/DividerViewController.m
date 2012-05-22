//
//  DividerViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-5-22.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "DividerViewController.h"
#import "NSDateAddition.h"

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
    NSTimeInterval interval = [date timeIntervalSinceNow];
    
    NSString *timeString = [date customString];
    CGFloat timeStringWidth = ceilf([timeString sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(1000.0, 30.0) lineBreakMode:UILineBreakModeWordWrap].width);
    [self view:self.timeLabel resetWidth:timeStringWidth];
    [self view:self.timeLabel resetOriginX:[self currentScreenWidth] / 2 - timeStringWidth / 2 + 3];
    [self view:self.leftPattern resetOriginX:[self currentScreenWidth] / 2 - timeStringWidth / 2 - 30];
    [self view:self.rightPattern resetOriginX:[self currentScreenWidth] / 2 + timeStringWidth / 2 + 5];
    
    self.timeLabel.text = timeString;
        
//    [self view:self.leftPattern resetOriginX:];
}

- (CGFloat)currentScreenWidth
{
    BOOL isPortrait = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);;
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

@end
