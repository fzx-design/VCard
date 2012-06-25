//
//  MotionsViewController.m
//  VCard
//
//  Created by 紫川 王 on 12-4-11.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "MotionsViewController.h"

@interface MotionsViewController ()

@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) UIImage *modifiedImage;
@property (nonatomic, assign) CGRect leftCameraCoverCloseFrame;
@property (nonatomic, assign) CGRect rightCameraCoverCloseFrame;

@end

@implementation MotionsViewController

@synthesize shootViewController = _shootViewController;
@synthesize editViewController = _editViewController;
@synthesize logoImageView = _logoImageView;
@synthesize bgImageView = _bgImageView;
@synthesize captureBgView = _captureBgView;
@synthesize delegate = _delegate;

@synthesize originalImage = _originalImage;
@synthesize modifiedImage = _modifiedImage;
@synthesize cancelButton = _cancelButton;
@synthesize leftCameraCoverCloseFrame = _leftCameraCoverCloseFrame;
@synthesize rightCameraCoverCloseFrame = _rightCameraCoverCloseFrame;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSString *nibName = nil;
    if(UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        nibName = [NSString stringWithFormat:@"%@-landscape", NSStringFromClass([self class])];
    } else {
        nibName = [NSString stringWithFormat:@"%@", NSStringFromClass([self class])];
    }
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithImage:(UIImage *)image {
    self = [self init];
    if(self) {
        self.originalImage = image;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configureCameraCover];
    if(self.originalImage) {
    } else {
        [self configureShootViewController];
        [self.shootViewController configureOrientation:[[UIDevice currentDevice] orientation]];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.logoImageView = nil;
    self.bgImageView = nil;
    self.captureBgView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    NSLog(@"will rotate to:%d", toInterfaceOrientation);
    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@-landscape", NSStringFromClass([self class])] owner:self options:nil];
        if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
            self.view.transform = CGAffineTransformMakeRotation(M_PI * 3 / 2);
        else
            self.view.transform = CGAffineTransformMakeRotation(M_PI / 2);
    } else {
        [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@", NSStringFromClass([self class])] owner:self options:nil];
        if (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
            self.view.transform = CGAffineTransformMakeRotation(M_PI);
    }
    [self viewDidLoad];
}

#pragma mark - Logic methods

- (MotionsShootViewController *)shootViewController {
    if(!_shootViewController) {
        _shootViewController = [[MotionsShootViewController alloc] init];
        _shootViewController.delegate = self;
    }
    return _shootViewController;
}

- (MotionsEditViewController *)editViewController {
    if(!_editViewController) {
        _editViewController = [[MotionsEditViewController alloc] init];
        //_editViewController.delegate = self;
    }
    return _editViewController;
}

#pragma mark - UI methods

- (void)configureCameraCover {
    self.leftCameraCoverCloseFrame = self.leftCameraCoverImageView.frame;
    self.rightCameraCoverCloseFrame = self.rightCameraCoverImageView.frame;
}

- (void)configureShootViewController {
    [self.shootViewController.view removeFromSuperview];
    [self.view insertSubview:self.shootViewController.view aboveSubview:self.captureBgView];
}

- (void)configureEditViewController {
    [self.editViewController.view removeFromSuperview];
    [self.view insertSubview:self.editViewController.view aboveSubview:self.captureBgView];
}

#pragma mark - IBActions

- (IBAction)didClickCancelButton:(UIButton *)sender {
    [self.delegate motionViewControllerDidCancel];
}

#pragma mark - Animations

- (void)showCameraCoverWithCompletion:(void (^)(void))completion {
    self.shootViewController.cameraStatusLEDButton.selected = NO;
    [UIView animateWithDuration:0.3f animations:^{
        self.leftCameraCoverImageView.frame = self.leftCameraCoverCloseFrame;
        self.rightCameraCoverImageView.frame = self.rightCameraCoverCloseFrame;
    } completion:^(BOOL finished) {
        if(completion)
            completion();
    }];
}

- (void)hideCameraCoverWithCompletion:(void (^)(void))completion {
    [UIView animateWithDuration:0.3f animations:^{
        CGRect frame = self.leftCameraCoverCloseFrame;
        frame.origin.x = frame.origin.x - frame.size.width;
        self.leftCameraCoverImageView.frame = frame;
        frame = self.rightCameraCoverCloseFrame;
        frame.origin.x = frame.origin.x + frame.size.width;
        self.rightCameraCoverImageView.frame = frame;
    } completion:^(BOOL finished) {
        if(completion)
            completion();
        self.shootViewController.cameraStatusLEDButton.selected = YES;
    }];
}

#pragma mark - MotionsShootViewController delegate

- (void)shootViewController:(MotionsShootViewController *)vc didCaptureImage:(UIImage *)image {
    
}

- (void)shootViewControllerWillBecomeActiveWithCompletion:(void (^)(void))completion {
    [self hideCameraCoverWithCompletion:completion];
}

- (void)shootViewControllerWillBecomeInactiveWithCompletion:(void (^)(void))completion {
    [self showCameraCoverWithCompletion:completion];
}

@end
