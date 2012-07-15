//
//  SettingViewController.m
//  VCard
//
//  Created by 王 紫川 on 12-7-12.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "TipsViewController.h"
#import "UIApplication+Addition.h"
#import "UIView+Resize.h"

#define NUMBER_OF_TIP_PAGES         6
#define TIP_IMAGE_FILE_NAME_PREFIX  @"fingertips_"
#define TIP_TEXT_FILE_NAME_PREFIX   @"fingertips_text_chn_"

@interface TipsViewController ()

@end

@implementation TipsViewController

@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize finishButton = _finishButton;
@synthesize iconImageView = _iconImageView;
@synthesize welcomeImageView = _welcomeImageView;

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
    // Do any additional setup after loading the view from its nib.
    self.view.frame = CGRectMake(0, 0, [UIApplication screenWidth], [UIApplication screenHeight]);
    
    [self configureScrollView];
    [self configurePageControl];
    
    self.welcomeImageView.hidden = YES;
    self.iconImageView.hidden = YES;
    self.view.userInteractionEnabled = NO;
    [self performSelector:@selector(viewAppearAnimation) withObject:nil afterDelay:0.7f];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Dispose of any resources that can be recreated.
    self.scrollView = nil;
    self.pageControl = nil;
    self.finishButton = nil;
    self.iconImageView = nil;
    self.welcomeImageView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Logic methods 

#pragma mark - UI methods 

- (void)show {
    [UIApplication presentModalViewController:self animated:YES];
}

- (void)configureScrollView {
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * NUMBER_OF_TIP_PAGES, self.scrollView.frame.size.height);
    for(int i = 0; i < NUMBER_OF_TIP_PAGES - 1; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%d", TIP_IMAGE_FILE_NAME_PREFIX, i + 1]]];
        UIImageView *textView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%d", TIP_TEXT_FILE_NAME_PREFIX, i + 1]]];
        
        imageView.center = CGPointMake(self.scrollView.frame.size.width * (0.5f + i + 1), imageView.frame.size.height / 2);
        textView.center = CGPointMake(self.scrollView.frame.size.width * (0.5f + i + 1), imageView.frame.size.height + textView.frame.size.height / 2 + 40);
        
        [self.scrollView addSubview:imageView];
        [self.scrollView addSubview:textView];
    }
    
    self.finishButton.center = CGPointMake(5.5f * self.scrollView.frame.size.width, self.finishButton.center.y);
}

- (void)configurePageControl {
    self.pageControl.numberOfPages = NUMBER_OF_TIP_PAGES;
    [self.pageControl setImageNormal:[UIImage imageNamed:@"shelf_pagecontrol_bg.png"]];
    [self.pageControl setImageCurrent:[UIImage imageNamed:@"shelf_pagecontrol_hover.png"]];
    [self.pageControl setImageSetting:[UIImage imageNamed:@"shelf_pagecontrol_bg.png"]];
    [self.pageControl setImageSettingHighlight:[UIImage imageNamed:@"shelf_pagecontrol_hover.png"]];
    
    [self.pageControl setCurrentPage:0];
}

#pragma mark - IBActions

- (IBAction)didClickFinishButton:(UIButton *)sender {
    [UIApplication dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger page = fabs(scrollView.contentOffset.x) / scrollView.frame.size.width;
    self.pageControl.currentPage = page;
}

#pragma mark - Animation methods

- (void)viewAppearAnimation {
    CGRect iconFrame = self.iconImageView.frame;
    self.iconImageView.center = CGPointMake(self.iconImageView.center.x, self.scrollView.frame.size.height / 2);
    
    self.welcomeImageView.hidden = NO;
    self.iconImageView.hidden = NO;
    
    self.welcomeImageView.alpha = 0;
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [UIView animateWithDuration:0.5f delay:0.3f options:UIViewAnimationCurveEaseInOut animations:^{
            self.iconImageView.frame = iconFrame;
            self.welcomeImageView.alpha = 1;
        } completion:^(BOOL finished) {
            self.view.userInteractionEnabled = YES;
        }];
	}];
    
    [CATransaction setValue:[NSNumber numberWithFloat:0.3f] forKey: kCATransactionAnimationDuration];
    [self.iconImageView.layer addAnimation:[TipsViewController popoverAnimation] forKey:nil];
    [CATransaction commit];
}

+ (CAKeyframeAnimation*)popoverAnimation {
	CAKeyframeAnimation * animation; 
	animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"]; 
	animation.duration = 0.5; 
	animation.delegate = self;
	animation.removedOnCompletion = YES;
	animation.fillMode = kCAFillModeForwards;
	
	NSMutableArray *values = [NSMutableArray array];
	[values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
	[values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]]; 
	[values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 0.9)]]; 
	[values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
	
	animation.values = values;
	return animation;
}

@end
