//
//  NewLoginViewController.m
//  VCard
//
//  Created by 王 紫川 on 12-7-9.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "NewLoginViewController.h"
#import "UIApplication+Addition.h"
#import <QuartzCore/QuartzCore.h>
#import "LoginCellViewController.h"

#define VIEW_APPEAR_ANIMATION_DURATION 0.5f

@interface NewLoginViewController ()

@property (nonatomic, strong) NSMutableArray *cellControllerArray;
@property (nonatomic, strong) NSMutableArray *loginUserInfoArray;
@property (nonatomic, assign) NSUInteger currentCellIndex;

@end

@implementation NewLoginViewController

@synthesize registerButton = _registerButton;
@synthesize bgView = _bgView;
@synthesize scrollView = _scrollView;

@synthesize cellControllerArray = _cellControllerArray;
@synthesize loginUserInfoArray = _loginUserInfoArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.cellControllerArray = [NSMutableArray array];
        self.loginUserInfoArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configureUI];
    [self viewAppearAnimation];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Dispose of any resources that can be recreated.
    self.bgView = nil;
    self.registerButton = nil;
    self.scrollView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewWillLayoutSubviews {
    [self layoutScrollView];
}

#pragma mark - UI methods

- (void)configureUI {
    [ThemeResourceProvider configButtonPaperLight:self.registerButton];
    self.view.frame = CGRectMake(0, 0, [UIApplication screenWidth], [UIApplication screenHeight]);
    
    [self configureScrollView];
}

- (void)configureScrollView {
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * [self numberOfCellsInScrollView], self.scrollView.frame.size.height);
    
    for(NSUInteger i = 0; i < [self numberOfCellsInScrollView]; i++) {
        UIViewController *vc = [self cellControllerAtIndex:i];
        vc.view.center = CGPointMake(self.scrollView.frame.size.width * (i + 0.5f), self.scrollView.frame.size.height / 2);
        [self.scrollView addSubview:vc.view];
    }
}

- (void)layoutScrollView {
    for(NSUInteger i = 0; i < [self numberOfCellsInScrollView]; i++) {
        UIViewController *vc = [self cellControllerAtIndex:i];
        vc.view.center = CGPointMake(self.scrollView.frame.size.width * (i + 0.5f), self.scrollView.frame.size.height / 2);
    }
    
    self.scrollView.contentOffset = CGPointMake(self.currentCellIndex * self.scrollView.frame.size.width, 0);
}

- (void)show {
    [UIApplication presentModalViewController:self animated:NO duration:VIEW_APPEAR_ANIMATION_DURATION];
}

#pragma mark - Logic methods

- (NSUInteger)numberOfCellsInScrollView {
    return 4;
}

- (UIViewController *)cellControllerAtIndex:(NSUInteger)index {
    if(index >= self.cellControllerArray.count) {
        LoginCellViewController *vc = [[LoginCellViewController alloc] init];
        [self.cellControllerArray addObject:vc];
        return vc;
    } else {
        return [self.cellControllerArray objectAtIndex:index];
    }
}

#pragma mark - Animations

- (void)viewAppearAnimation {
    __block CGRect frame = self.view.frame;
    frame.origin = CGPointMake(0, -frame.size.height);
    self.view.frame = frame;
    [UIView animateWithDuration:VIEW_APPEAR_ANIMATION_DURATION animations:^{
        frame.origin = CGPointMake(0, 0);
        self.view.frame = frame;
    }];
}

- (void)viewDisappearAnimation {
    __block CGRect frame = self.view.frame;
    frame.origin = CGPointMake(0, 0);
    self.view.frame = frame;
    [UIView animateWithDuration:VIEW_APPEAR_ANIMATION_DURATION animations:^{
        frame.origin = CGPointMake(0, -frame.size.height);
        self.view.frame = frame;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
    [UIApplication dismissModalViewControllerAnimated:NO duration:VIEW_APPEAR_ANIMATION_DURATION];
}

#pragma mark - IBActions 

- (IBAction)didClickRegisterButton:(UIButton *)sender {
    [self viewDisappearAnimation];
}

#pragma mark - UIScrollView delegate


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSUInteger index = fabs(scrollView.contentOffset.x) / scrollView.frame.size.width;
    self.currentCellIndex = index;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSUInteger index = fabs(scrollView.contentOffset.x) / scrollView.frame.size.width;
    self.currentCellIndex = index;
}

@end
