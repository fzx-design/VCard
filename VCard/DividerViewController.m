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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetLayoutAfterRotating)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)updateTimeInformation:(NSDate *)date
{
    NSDate *currentDate = [NSDate date];
    NSTimeInterval interval = [currentDate timeIntervalSinceDate:date];
    
    int minutes = floor(interval / 60);
    
    NSString *timeString;
    if (minutes > 60) {
        timeString = [date customString];
    } else if (minutes == 0) {
        timeString = [NSString stringWithFormat:@" 刚刚更新 "];
    } else {
        timeString = [NSString stringWithFormat:@"%d 分钟前", minutes];
    }
    
    self.timeLabel.text = timeString;
    
    [self resetLayoutAfterRotating];
}

- (void)resetLayoutAfterRotating
{
    CGFloat timeStringWidth = ceilf([self.timeLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:12.0f] constrainedToSize:CGSizeMake(1000.0, 30.0) lineBreakMode:UILineBreakModeWordWrap].width) + 1;
    [self view:self.timeLabel resetWidth:timeStringWidth];
    [self view:self.timeLabel resetOriginX:[self currentScreenWidth] / 2 - timeStringWidth / 2 + 4];
    [self view:self.leftPattern resetOriginX:[self currentScreenWidth] / 2 - timeStringWidth / 2 - 32];
    [self view:self.rightPattern resetOriginX:[self currentScreenWidth] / 2 + timeStringWidth / 2 + 5];
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
