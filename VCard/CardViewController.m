//
//  CardViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-4-14.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CardViewController.h"
#import "UIImageViewAddition.h"
#import "User.h"

#define MaxCardSize CGSizeMake(326,9999)
#define CardSizeUserAvatarHeight 25
#define CardSizeImageGap 22
#define CardSizeTextGap 15
#define CardSizeTopViewHeight 20
#define CardSizeBottomViewHeight 36


@interface CardViewController () {
    BOOL _doesImageExist;
    BOOL _isReposted;
}

@end

@implementation CardViewController

@synthesize statusImageView = _statusImageView;
@synthesize repostUserAvatar = _repostUserAvatar;
@synthesize originalUserAvatar = _originalUserAvatar;
@synthesize favoredImageView = _favoredImageView;
@synthesize clipImageView = _clipImageView;
@synthesize commentButton = _commentButton;
@synthesize repostButton = _repostButton;
@synthesize originalUserNameButton = _originalUserNameButton;
@synthesize repostUserNameButton = _repostUserNameButton;
@synthesize statusInfoView = _statusInfoView;
@synthesize originalStatusLabel = _originalStatusLabel;
@synthesize repostStatusLabel = _repostStatusLabel;
@synthesize cardBackground = _cardBackground;
@synthesize repostCardBackground = _repostCardBackground;
@synthesize status = _status;
@synthesize imageHeight = _imageHeight;

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Functional Method

+ (CGFloat)heightForStatus:(Status*)status_ andImageHeight:(NSInteger)imageHeight_
{
    BOOL isReposted = status_.repostStatus != nil;
    
    Status *targetStatus = isReposted ? status_.repostStatus : status_;
    BOOL doesImageExist = targetStatus.bmiddlePicURL && ![targetStatus.bmiddlePicURL isEqualToString:@""];

    CGFloat height = CardSizeTopViewHeight + CardSizeBottomViewHeight + CardSizeUserAvatarHeight;
    
    CGSize expectedTextSize = [status_.text sizeWithFont:[UIFont boldSystemFontOfSize:17.0f]                       
                                 constrainedToSize:MaxCardSize 
                                     lineBreakMode:UILineBreakModeCharacterWrap];
    
    height += expectedTextSize.height + CardSizeTextGap;
    
    if (isReposted) {
        height +=  CardSizeBottomViewHeight + CardSizeUserAvatarHeight - 5;
        expectedTextSize = [status_.repostStatus.text sizeWithFont:[UIFont boldSystemFontOfSize:17.0f]                       
                                    constrainedToSize:MaxCardSize 
                                        lineBreakMode:UILineBreakModeCharacterWrap];
        
        height += expectedTextSize.height + CardSizeTextGap;
    }
    
    if (doesImageExist) {
        height += imageHeight_;
    }
    
    return height;
}

- (void)configureCardWithStatus:(Status*)status_ imageHeight:(CGFloat)imageHeight_
{
    [self setUpStatus:status_];
    
    self.imageHeight = _doesImageExist ? imageHeight_ : 0.0;
    
    [self setUpStatusView];
    
    [self setUpRepostView];
    
    [self setUpStatusImageView];
    
}

- (void)setUpStatus:(Status*)status_
{
    self.status = status_;
    _isReposted = self.status.repostStatus != nil;
    
    Status *imageStatus = _isReposted ? self.status.repostStatus : self.status;
    
    _doesImageExist = imageStatus.bmiddlePicURL && ![imageStatus.bmiddlePicURL isEqualToString:@""];
    
}

- (void)setUpStatusImageView
{
    self.statusImageView.hidden = !_doesImageExist;
    self.clipImageView.hidden = !_doesImageExist;
    
    Status *targetStatus = _isReposted ? self.status.repostStatus : self.status;
    
    if (_doesImageExist) {
        
        CGRect frame = self.statusImageView.frame;
        frame.origin = CGPointMake(-4.0, 13.0);
        frame.size = CGSizeMake(StatusImageWidth, 200);
        
        self.statusImageView.frame = frame;
        
        [self.statusImageView resetHeight:self.imageHeight];
        
        [self.statusImageView loadTweetImageFromURL:targetStatus.bmiddlePicURL 
                                         completion:nil];
    }
}

- (void)setUpStatusView
{
    self.favoredImageView.hidden = ![self.status.favorited boolValue];
    
    CGFloat originY = _doesImageExist ? self.imageHeight + 30 : 20;
    Status *targetStatus = _isReposted ? self.status.repostStatus : self.status;

    [self setStatusTextLabel:self.originalStatusLabel withText:targetStatus.text];
    [self.originalUserAvatar loadImageFromURL:targetStatus.author.profileImageURL completion:nil];
    [self.originalUserNameButton setTitle:targetStatus.author.screenName forState:UIControlStateNormal];
    
    CGFloat statusViewHeight = self.originalStatusLabel.frame.size.height + 100;
    
    CGRect statusInfoFrame;
    statusInfoFrame.origin = CGPointMake(0.0, originY);
    statusInfoFrame.size = CGSizeMake(self.view.frame.size.width, statusViewHeight);
    self.statusInfoView.frame = statusInfoFrame;
    
    [self.cardBackground resetHeight:self.imageHeight + statusViewHeight];
}

- (void)setUpRepostView
{
    self.repostCardBackground.hidden = !_isReposted;
    if (_isReposted) {
        self.repostCardBackground.hidden = NO;
        
        Status *targetStatus = self.status;
        
        [self setStatusTextLabel:self.repostStatusLabel withText:targetStatus.text];
        [self.repostUserAvatar loadImageFromURL:targetStatus.author.profileImageURL completion:nil];
        [self.repostUserNameButton setTitle:targetStatus.author.screenName forState:UIControlStateNormal];
        
        CGRect bgFrame = self.repostCardBackground.frame;
        bgFrame.origin.x = self.cardBackground.frame.origin.x;
        bgFrame.origin.y = self.cardBackground.frame.origin.y + self.cardBackground.frame.size.height - 8;
  
        self.repostCardBackground.frame = bgFrame;
        
        [self.repostCardBackground resetHeight:self.repostStatusLabel.frame.size.height + 80];

    }
}

- (void)setStatusTextLabel:(IFTweetLabel*)label withText:(NSString*)string
{
    CGSize expectedTextSize = [string sizeWithFont:[UIFont boldSystemFontOfSize:17.0f]                       
                                            constrainedToSize:MaxCardSize 
                                                lineBreakMode:UILineBreakModeCharacterWrap];
    
    CGRect frame = label.frame;
    frame.size = expectedTextSize;
    label.frame = frame;
    
    [label setFont:[UIFont boldSystemFontOfSize:17.0f]];
	[label setTextColor:[UIColor colorWithRed:49.0/255 green:42.0/255 blue:37.0/255 alpha:1.0]];
	[label setBackgroundColor:[UIColor clearColor]];
	[label setNumberOfLines:20];
    [label setText:string];
    [label setLinksEnabled:YES];
}

@end
