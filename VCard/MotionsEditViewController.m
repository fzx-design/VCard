//
//  MotionsEditViewController.m
//  VCard
//
//  Created by 王 紫川 on 12-6-25.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "MotionsEditViewController.h"
#import "UIImage+Addition.h"
#import "UIView+Addition.h"
#import "CropImageViewController.h"

#define CROP_BUTTON_TAG 1001

@interface MotionsEditViewController ()

@property (nonatomic, assign, getter = isDirty) BOOL dirty;
@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) UIImage *modifiedImage;
@property (nonatomic, strong) UIImage *filterImage;
@property (nonatomic, readonly) UIImage *filteredImage;
@property (nonatomic, assign) UIInterfaceOrientation currentInterfaceOrientation;
@property (nonatomic, strong) CropImageViewController *cropImageViewController;

@end

@implementation MotionsEditViewController

@synthesize tableView = _tableView;
@synthesize cropButton = _cropButton;
@synthesize shadowAmountSlider = _shadowAmountSlider;
@synthesize filterImageView = _filterImageView;
@synthesize changePictureButton = _changePictureButton;
@synthesize finishEditButton = _finishEditButton;
@synthesize revertButton = _revertButton;
@synthesize delegate = _delegate;
@synthesize bgView = _bgView;
@synthesize functionView = _functionView;
@synthesize capturedImageView = _capturedImageView;
@synthesize capturedImageEditView = _capturedImageEditView;

@synthesize originalImage = _originalImage;
@synthesize modifiedImage = _modifiedImage;
@synthesize filterImage = _filterImage;
@synthesize currentInterfaceOrientation = _currentInterfaceOrientation;
@synthesize dirty = _dirty;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.currentInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    }
    return self;
}

- (id)initWithImage:(UIImage *)image {
    self = [self init];
    if(self) {
        self.originalImage = image;
        self.modifiedImage = self.originalImage;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //[self performSelector:@selector(configureFilterImageView) withObject:nil afterDelay:0.3f];
    self.capturedImageView.image = self.modifiedImage;
    [self configureSlider];
    [self configureButtons];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Dispose of any resources that can be recreated.
    self.tableView = nil;
    self.cropButton = nil;
    self.shadowAmountSlider = nil;
    self.filterImageView = nil;
    self.changePictureButton = nil;
    self.revertButton = nil;
    self.finishEditButton = nil;
    self.bgView = nil;
    self.functionView = nil;
    self.capturedImageView = nil;
    self.capturedImageEditView = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [self configureFilterImageView];
}

- (void)loadViewControllerWithInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    self.currentInterfaceOrientation = interfaceOrientation;
    [super loadViewControllerWithInterfaceOrientation:interfaceOrientation];
}

#pragma mark - Logic methods

- (UIImage *)filteredImage {
    UIImage *filteredImage = [self.modifiedImage shadowAmount:self.shadowAmountSlider.value];
    return filteredImage;
}

#pragma mark - Animations 

- (void)semiTransparentEditViewForCropAnimation {
    [UIView animateWithDuration:0.3f animations:^{
        for(UIView *subview in self.functionView.subviews) {
            if(subview.tag != CROP_BUTTON_TAG) {
                subview.alpha = 0.2f;
                subview.userInteractionEnabled = NO;
            }
        }
    }];
}

- (void)opaqueEditViewAnimation {
    [UIView animateWithDuration:0.3f animations:^{
        for(UIView *subview in self.functionView.subviews) {
            subview.alpha = 1;
        }
    } completion:^(BOOL finished) {
        for(UIView *subview in self.functionView.subviews) {
            if([subview isMemberOfClass:[UIView class]])
                subview.userInteractionEnabled = YES;
        }
    }];
}

- (void)hideCropImageViewControllerAnimation {
    [self opaqueEditViewAnimation];
    self.cropButton.userInteractionEnabled = NO;
        
    [self.cropImageViewController.editBarView fadeOut];
    [self.capturedImageEditView fadeIn];
    
    [self.cropImageViewController zoomOutToCenter:self.filterImageView.center withScaleFactor:self.capturedImageView.contentScaleFactor completion:^{
        [self.cropImageViewController.view removeFromSuperview];
        self.cropImageViewController = nil;
        self.cropButton.userInteractionEnabled = YES;
        self.cropButton.selected = NO;
    }];
}

#pragma mark - UI methods

- (void)configureFilterImageView {
    UIImage *filterImage = [self.modifiedImage imageCroppedToFitSize:self.filterImageView.frame.size];
    [self.filterImageView setImage:filterImage];
    [self.filterImageView setNeedsDisplay];
    if(!self.filterImage)
        [self.filterImageView fadeIn];
    self.filterImage = filterImage;
    [(NSObject *)self.delegate performSelector:@selector(editViewControllerDidBecomeActiveWithCompletion:) withObject:nil afterDelay:0.3f];
}

- (void)configureSlider {
    [self.shadowAmountSlider setMinimumTrackImage:[UIImage imageNamed:@"transparent.png"] forState:UIControlStateNormal];
	[self.shadowAmountSlider setMaximumTrackImage:[UIImage imageNamed:@"transparent.png"] forState:UIControlStateNormal];
    if(UIInterfaceOrientationIsLandscape(self.currentInterfaceOrientation)) {
        [self.shadowAmountSlider setThumbImage:[UIImage imageNamed:@"motions_slider_thumb_horizon.png"] forState:UIControlStateNormal];
        self.shadowAmountSlider.transform = CGAffineTransformMakeRotation(M_PI / 2);
        CGRect frame = self.shadowAmountSlider.frame;
        frame.origin.x = (int)(frame.origin.x);
        frame.origin.y = (int)(frame.origin.y);
        self.shadowAmountSlider.frame = frame;
    } else {
        [self.shadowAmountSlider setThumbImage:[UIImage imageNamed:@"motions_slider_thumb_vertical.png"] forState:UIControlStateNormal];
    }
}

- (void)configureButtons {
    [ThemeResourceProvider configButtonDark:self.changePictureButton];
    [ThemeResourceProvider configButtonDark:self.revertButton];
}

- (void)resetSliders {
    [self.shadowAmountSlider setValue:0.5f animated:YES];
}

#pragma mark - IBActions

- (IBAction)didChangeSlider:(UISlider *)sender {
    float value = sender.value;
    self.filterImageView.shadowAmountValue = value;
    [self.filterImageView setNeedsDisplay];
}

- (IBAction)didClickCropButton:(UIButton *)sender {
    BOOL select = !sender.selected;
    if(select) {
        [self semiTransparentEditViewForCropAnimation];
        
        self.cropImageViewController = [[CropImageViewController alloc] initWithImage:self.modifiedImage filteredImage:self.filteredImage];
        self.cropImageViewController.delegate = self;
        self.cropImageViewController.view.frame = self.filterImageView.frame;
        
        [self.bgView insertSubview:self.cropImageViewController.view aboveSubview:self.filterImageView];
        
        self.cropButton.userInteractionEnabled = NO;
        [self.cropImageViewController zoomInFromCenter:self.filterImageView.center withScaleFactor:self.capturedImageView.contentScaleFactor completion:^{
            self.cropButton.userInteractionEnabled = YES;
            self.cropButton.selected = YES;
        }];
        
        [self.cropImageViewController.editBarView fadeIn];
        [self.capturedImageEditView fadeOut];
        
    } else {
        [self.cropImageViewController didClickFinishCropButton:sender];
    }
}

- (IBAction)didClickRevertButton:(UIButton *)sender {
    if(!self.isDirty) 
        return;
    
    [self resetSliders];
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithFrame:self.filterImageView.frame];
    tempImageView.image = self.filteredImage;
    tempImageView.contentMode = UIViewContentModeScaleAspectFill;
    [tempImageView setNeedsLayout];
    [self.view insertSubview:tempImageView aboveSubview:self.filterImageView];
    
    self.modifiedImage = self.originalImage;
    [self configureFilterImageView];
    [self.filterImageView initializeParameter];
    
    [tempImageView fadeOutWithCompletion:^{
        [tempImageView removeFromSuperview];
    }];
}

- (IBAction)didClickFinishEditButton:(UIButton *)sender {
    [self.delegate editViewControllerDidFinishEditImage:self.modifiedImage];
}

#pragma mark - TableView delegate & data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

#pragma mark - CropImageViewController delegate

- (void)cropImageViewControllerDidFinishCrop:(UIImage *)image {
    self.modifiedImage = image;
    [self configureFilterImageView];
    self.capturedImageView.image = image;
    [self hideCropImageViewControllerAnimation];
}

- (void)cropImageViewControllerDidCancelCrop {
    [self hideCropImageViewControllerAnimation];
}


@end
