//
//  CardViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-4-14.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "CardViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface CardViewController ()

@end

@implementation CardViewController

@synthesize statusImageView = _statusImageView;

@synthesize cardBackground = _cardBackground;
@synthesize repostCardBackground = _repostCardBackground;

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
    
    CGRect frame = self.repostCardBackground.frame;
    frame.origin.y = self.cardBackground.frame.origin.y + self.cardBackground.frame.size.height - 8;
    self.repostCardBackground.frame = frame;
    
    
    self.statusImageView.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.statusImageView.layer.shadowOffset = CGSizeMake(0, 1);
//    self.statusImageView.layer.shadowOpacity = 0.5;
//    self.statusImageView.layer.shadowRadius = 5.0;
//    self.statusImageView.clipsToBounds = NO;
    
    self.statusImageView.transform = CGAffineTransformMakeRotation(2 * M_PI / 180); //rotation in radians
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
