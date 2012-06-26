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
@property (nonatomic, assign) CGRect leftCameraCoverOpenFrame;
@property (nonatomic, assign) CGRect rightCameraCoverOpenFrame;
@property (nonatomic, assign, getter = isCameraCoverHidden) BOOL cameraCoverHidden;

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
@synthesize cameraCoverHidden = _cameraCoverHidden;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    [self loadInterfaceOrientation:toInterfaceOrientation];
}

#pragma mark - Logic methods

- (CGRect)leftCameraCoverOpenFrame {
    CGRect frame;
    if(UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        frame = self.leftCameraCoverCloseFrame;
        frame.origin.x = frame.origin.x - frame.size.width;
    } else {
        frame = self.leftCameraCoverCloseFrame;
        frame.origin.y = frame.origin.y - frame.size.height;
    }
    return frame;
}

- (CGRect)rightCameraCoverOpenFrame {
    CGRect frame;
    if(UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        frame = self.rightCameraCoverCloseFrame;
        frame.origin.x = frame.origin.x + frame.size.width;
    } else {
        frame = self.rightCameraCoverCloseFrame;
        frame.origin.y = frame.origin.y + frame.size.height;
    }
    return frame;
}

- (MotionsShootViewController *)shootViewController {
    if(!_shootViewController) {
        _shootViewController = [[MotionsShootViewController alloc] init];
        _shootViewController.delegate = self;
        [self.subViewControllers addObject:_shootViewController];
    }
    return _shootViewController;
}

- (MotionsEditViewController *)editViewController {
    if(!_editViewController) {
        _editViewController = [[MotionsEditViewController alloc] init];
        //_editViewController.delegate = self;
        [self.subViewControllers addObject:_editViewController];
    }
    return _editViewController;
}

#pragma mark - UI methods

- (void)configureCameraCover {
    self.leftCameraCoverCloseFrame = self.leftCameraCoverImageView.frame;
    self.rightCameraCoverCloseFrame = self.rightCameraCoverImageView.frame;
    if(self.isCameraCoverHidden) {
        self.leftCameraCoverImageView.frame = self.leftCameraCoverOpenFrame;
        self.rightCameraCoverImageView.frame = self.rightCameraCoverOpenFrame;
    }
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
    self.cameraCoverHidden = NO;
    [UIView animateWithDuration:0.3f animations:^{
        self.leftCameraCoverImageView.frame = self.leftCameraCoverCloseFrame;
        self.rightCameraCoverImageView.frame = self.rightCameraCoverCloseFrame;
    } completion:^(BOOL finished) {
        if(completion)
            completion();
    }];
}

- (void)hideCameraCoverWithCompletion:(void (^)(void))completion {
    self.cameraCoverHidden = YES;
    [UIView animateWithDuration:0.3f animations:^{
        self.leftCameraCoverImageView.frame = self.leftCameraCoverOpenFrame;
        self.rightCameraCoverImageView.frame = self.rightCameraCoverOpenFrame;
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
