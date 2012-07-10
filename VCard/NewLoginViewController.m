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

#define VIEW_APPEAR_ANIMATION_DURATION  0.5f

#define LOGO_VIEW_LANDSCAPE_CENTER      CGPointMake(512, 90)
#define LOGO_VIEW_PORTRAIT_CENTER       CGPointMake(384, 125)

#define SCROLL_VIEW_LANDSCAPE_CENTER    CGPointMake(512, 400)
#define SCROLL_VIEW_PORTRAIT_CENTER     CGPointMake(384, 480)

#define kLoginedUserArray @"LoginedUserArray"

@interface NewLoginViewController ()

@property (nonatomic, strong) NSMutableArray *cellControllerArray;
@property (nonatomic, strong) NSMutableArray *loginUserInfoArray;
@property (nonatomic, assign) NSUInteger currentCellIndex;
@property (nonatomic, assign) CGFloat keyboardHeight;

@end

@implementation NewLoginViewController

@synthesize registerButton = _registerButton;
@synthesize bgView = _bgView;
@synthesize scrollView = _scrollView;
@synthesize logoImageView = _logoImageView;
@synthesize delegate = _delegate;

@synthesize cellControllerArray = _cellControllerArray;
@synthesize loginUserInfoArray = _loginUserInfoArray;
@synthesize keyboardHeight = _keyboardHeight;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *storedArray = [defaults arrayForKey:kLoginedUserArray];
        self.loginUserInfoArray = [NSMutableArray arrayWithArray:storedArray];
        [storedArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            User *user = [User userWithID:obj inManagedObjectContext:self.managedObjectContext];
            [self.loginUserInfoArray addObject:user];
        }];
        
        self.cellControllerArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configureUI];
    [self viewAppearAnimation];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Dispose of any resources that can be recreated.
    self.bgView = nil;
    self.registerButton = nil;
    self.scrollView = nil;
    self.logoImageView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewWillLayoutSubviews {
    [self layoutSubviews];
}

#pragma mark - Notification handlers

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect keyboardBounds = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = [UIApplication isCurrentOrientationLandscape] ? keyboardBounds.size.width : keyboardBounds.size.height;
    self.keyboardHeight = keyboardHeight;
    
    [UIView animateWithDuration:0.3f animations:^{
        [self refreshComponentFrame];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.keyboardHeight = 0;
    [UIView animateWithDuration:0.3f animations:^{
        [self refreshComponentFrame];
    }];
}

#pragma mark - UI methods

- (void)configureUI {
    [ThemeResourceProvider configButtonPaperLight:self.registerButton];
    self.view.frame = CGRectMake(0, 0, [UIApplication screenWidth], [UIApplication screenHeight]);
    
    [self configureScrollView];
}

- (void)configureScrollView {
    CGFloat scrollViewContentWidth = [self numberOfCellsInScrollView] > 1 ? self.scrollView.frame.size.width * [self numberOfCellsInScrollView] : self.scrollView.frame.size.width + 1;
    self.scrollView.contentSize = CGSizeMake(scrollViewContentWidth, self.scrollView.frame.size.height);
    
    for(NSUInteger i = 0; i < [self numberOfCellsInScrollView]; i++) {
        UIViewController *vc = [self cellControllerAtIndex:i];
        vc.view.center = CGPointMake(self.scrollView.frame.size.width * (i + 0.5f), self.scrollView.frame.size.height / 2);
        [self.scrollView addSubview:vc.view];
    }
}

- (void)layoutSubviews {
    for(NSUInteger i = 0; i < [self numberOfCellsInScrollView]; i++) {
        UIViewController *vc = [self cellControllerAtIndex:i];
        vc.view.center = CGPointMake(self.scrollView.frame.size.width * (i + 0.5f), self.scrollView.frame.size.height / 2);
    }
    
    self.scrollView.contentOffset = CGPointMake(self.currentCellIndex * self.scrollView.frame.size.width, 0);
    
    [self refreshComponentFrame];
}

- (void)refreshComponentFrame {
    self.logoImageView.center = [UIApplication isCurrentOrientationLandscape] ? CGPointMake(LOGO_VIEW_LANDSCAPE_CENTER.x, LOGO_VIEW_LANDSCAPE_CENTER.y - self.keyboardHeight / 5 * 3) : LOGO_VIEW_PORTRAIT_CENTER;
    
    self.scrollView.center = [UIApplication isCurrentOrientationLandscape] ? CGPointMake(SCROLL_VIEW_LANDSCAPE_CENTER.x, SCROLL_VIEW_LANDSCAPE_CENTER.y - self.keyboardHeight / 5 * 3) : SCROLL_VIEW_PORTRAIT_CENTER;
}

- (void)show {
    [UIApplication presentModalViewController:self animated:NO duration:VIEW_APPEAR_ANIMATION_DURATION];
}

#pragma mark - Logic methods

- (void)setCurrentCellIndex:(NSUInteger)currentCellIndex {
    if(_currentCellIndex != currentCellIndex) {
        [self.view endEditing:YES];
    }
    _currentCellIndex = currentCellIndex;
}

- (NSUInteger)numberOfCellsInScrollView {
    return self.loginUserInfoArray.count + 1;
}

- (UIViewController *)cellControllerAtIndex:(NSUInteger)index {
    if(index >= self.cellControllerArray.count) {
        UIViewController *vc = nil;
        if(self.loginUserInfoArray.count <= index) {
            vc = [[LoginCellViewController alloc] init];
            ((LoginCellViewController *)vc).delegate = self;
        } else {
            User *user = [self.loginUserInfoArray objectAtIndex:index];
            vc = [[LoginUserCellViewController alloc] initWithUser:user];
            ((LoginUserCellViewController *)vc).delegate = self;
        }
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
}

#pragma mark - IBActions 

- (IBAction)didClickRegisterButton:(UIButton *)sender {
    [self viewDisappearAnimation];
    [UIApplication dismissModalViewControllerAnimated:NO duration:VIEW_APPEAR_ANIMATION_DURATION];
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

#pragma mark - LoginUserCellViewController delegate

- (void)loginUserCell:(LoginUserCellViewController *)vc didSelectUser:(User *)user {
    [self.delegate loginViewController:self didSelectUser:user];
}

- (void)loginUserCell:(LoginUserCellViewController *)vc didDeleteUser:(User *)user {
    
}

#pragma mark - LoginCellViewController delegate

- (void)loginCell:(LoginCellViewController *)vc didLoginUser:(User *)user {
    NSMutableArray *userIDArray = [NSMutableArray array];
    [self.loginUserInfoArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        User *user = obj;
        [userIDArray addObject:user.userID];
    }];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:userIDArray forKey:kLoginedUserArray];
    [defaults synchronize];
    
    [self viewDisappearAnimation];
    [UIApplication dismissModalViewControllerAnimated:NO duration:VIEW_APPEAR_ANIMATION_DURATION];
}

@end
