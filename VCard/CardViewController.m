//
//  CardViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-4-14.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "CardViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "IFTweetLabel.h"

@interface CardViewController ()

@end

@implementation CardViewController

@synthesize statusImageView = _statusImageView;
@synthesize statusInfoView = _statusInfoView;
@synthesize statusTextLabel = _statusTextLabel;

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
    CGRect statusInfoFrame;
    statusInfoFrame.origin = CGPointMake(0.0, self.statusImageView.frame.size.height + 20);
    statusInfoFrame.size = CGSizeMake(self.view.frame.size.width, 100);
    self.statusInfoView.frame = statusInfoFrame;
    
    CGRect bgFrame = self.repostCardBackground.frame;
    bgFrame.origin.y = self.cardBackground.frame.origin.y + self.cardBackground.frame.size.height - 8;
    self.repostCardBackground.frame = bgFrame;
    
    [self.statusTextLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
	[self.statusTextLabel setTextColor:[UIColor blackColor]];
	[self.statusTextLabel setBackgroundColor:[UIColor clearColor]];
	[self.statusTextLabel setNumberOfLines:10];
	[self.statusTextLabel setText:@"This is a #test# of regular expressions with http://example.com links as used in @Twitterrific. HTTP://CHOCKLOCK.COM APPROVED OF COURSE. 哈哈哈哈哈h哈哈哈哈哈哈哈h哈哈哈哈哈哈哈h哈哈哈哈哈哈哈h哈哈哈哈哈哈哈h哈哈哈哈哈哈哈h哈哈哈哈哈哈哈h哈哈哈哈哈哈哈h哈哈哈哈哈哈哈h哈哈哈哈哈哈哈h哈哈"];
	[self.statusTextLabel setLinksEnabled:YES];    
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
