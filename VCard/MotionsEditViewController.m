//
//  MotionsEditViewController.m
//  VCard
//
//  Created by 王 紫川 on 12-6-25.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "MotionsEditViewController.h"
#import "UIImage+Addition.h"

@interface MotionsEditViewController ()

@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) UIImage *modifiedImage;

@end

@implementation MotionsEditViewController

@synthesize tableView = _tableView;
@synthesize cropButton = _cropButton;
@synthesize shadowAmountSlider = _shadowAmountSlider;
@synthesize filterImageView = _filterImageView;
@synthesize delegate = _delegate;

@synthesize originalImage = _originalImage;
@synthesize modifiedImage = _modifiedImage;

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
    //[self performSelector:@selector(configureFilterImageView) withObject:nil afterDelay:0.3f];
    [self configureSlider];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Dispose of any resources that can be recreated.
    self.tableView = nil;
    self.cropButton = nil;
    self.shadowAmountSlider = nil;
    self.filterImageView = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [self performSelector:@selector(configureFilterImageView) withObject:nil afterDelay:0.3f];
}

#pragma mark - UI methods

- (void)configureFilterImageView {
    UIImage *filterImage = [self.originalImage imageCroppedToFitSize:self.filterImageView.frame.size];
    [self.filterImageView setImage:filterImage];
    [self.filterImageView setNeedsDisplay];
    [self.delegate editViewControllerDidBecomeActiveWithCompletion:nil];
}

- (void)configureSlider {
    [self.shadowAmountSlider setMinimumTrackImage:[UIImage imageNamed:@"transparent.png"] forState:UIControlStateNormal];
	[self.shadowAmountSlider setMaximumTrackImage:[UIImage imageNamed:@"transparent.png"] forState:UIControlStateNormal];
    if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        [self.shadowAmountSlider setThumbImage:[UIImage imageNamed:@"motions_slider_thumb_horizon.png"] forState:UIControlStateNormal];
    } else {
        [self.shadowAmountSlider setThumbImage:[UIImage imageNamed:@"motions_slider_thumb_vertical.png"] forState:UIControlStateNormal];
    }
    self.shadowAmountSlider.transform = CGAffineTransformMakeRotation(-M_PI / 2);
}

#pragma mark - IBActions

- (IBAction)didChangeSlider:(UISlider *)sender {
    
}

- (IBAction)didClickCropButton:(UIButton *)sender {
    
}

- (IBAction)didClickRevertButton:(UIButton *)sender {
    
}

- (IBAction)didClickFinishEditButton:(UIButton *)sender {
    [self.delegate editViewControllerDidFinishEditImage:self.modifiedImage];
}

#pragma mark - TableView delegate & data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

@end
