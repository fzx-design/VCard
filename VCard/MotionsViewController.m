//
//  MotionsViewController.m
//  VCard
//
//  Created by 紫川 王 on 12-4-11.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "MotionsViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Addition.h"
#import "MotionsFilterTableViewController.h"
#import "UIImage+Addition.h"
#import "UIView+Addition.h"
#import "UIImageView+ContentScale.h"

@interface MotionsViewController ()

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) MotionsFilterTableViewController *effectShelfViewController;
@property (nonatomic, strong) AVCaptureDeviceInput *backFacingCameraDeviceInput;
@property (nonatomic, strong) AVCaptureDeviceInput *frontFacingCameraDeviceInput;
@property (nonatomic, strong) AVCaptureDevice *currentDevice;
@property (nonatomic, strong) CropImageViewController *cropImageViewController;
@property (nonatomic, strong) UIImage *originImage;
@property (nonatomic, strong) UIImage *modifiedImage;
@property (nonatomic, readonly, getter = isDirty) BOOL dirty;
@property (nonatomic, readonly) UIImage *filteredImage;
@property (nonatomic, strong) UIPopoverController *popoverController;

@end

@implementation MotionsViewController

@synthesize cameraPreviewView = _cameraPreviewView;
@synthesize cameraCoverImageView = _cameraCoverImageView;
@synthesize filterImageView = _filterImageView;
@synthesize capturedImageEditView = _capturedImageEditView;
@synthesize captureSession = _captureSession;
@synthesize previewLayer = _previewLayer;
@synthesize stillImageOutput = _stillImageOutput;
@synthesize solarSlider = _solarSlider;
@synthesize contrastSlider = _contrastSlider;
@synthesize shotView = _shotView;
@synthesize editView = editView;
@synthesize delegate = _delegate;
@synthesize cameraPreviewBgView = _cameraPreviewBgView;
@synthesize cameraStatusLEDButton = _cameraStatusLEDButton;
@synthesize effectShelfViewController = _effectShelfViewController;
@synthesize effectShelfCoverImageView = _effectShelfCoverImageView;
@synthesize backFacingCameraDeviceInput = _backFacingCameraDeviceInput;
@synthesize frontFacingCameraDeviceInput = _frontFacingCameraDeviceInput;
@synthesize currentDevice = _currentDevice;
@synthesize optimizeButton = _optimizeButton;
@synthesize cropButton = _cropButton;
@synthesize cropImageViewController = _cropImageViewController;
@synthesize capturedImageView = _capturedImageView;
@synthesize finishCropButton = _finishCropButton;
@synthesize originImage = _originImage;
@synthesize modifiedImage = _modifiedImage;
@synthesize popoverController = _pc;

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
    [self configureCaptureSession];
    [self configureUI];
    self.view.userInteractionEnabled = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.cameraPreviewView = nil;
    self.shotView = nil;
    self.editView = nil;
    self.solarSlider = nil;
    self.contrastSlider = nil;
    self.cameraCoverImageView = nil;
    self.cameraPreviewBgView = nil;
    self.cameraStatusLEDButton = nil;
    self.capturedImageEditView = nil;
    self.effectShelfCoverImageView = nil;
    self.filterImageView = nil;
    self.optimizeButton = nil;
    self.cropButton = nil;
    self.finishCropButton = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [self openCamera];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        if(self.previewLayer.orientationSupported)
            self.previewLayer.orientation = AVCaptureVideoOrientationLandscapeLeft;
    }
    else if(interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        if(self.previewLayer.orientationSupported)
            self.previewLayer.orientation = AVCaptureVideoOrientationLandscapeRight;
    }
	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation ==UIInterfaceOrientationLandscapeRight);
}

- (BOOL)isDirty {
    if(self.originImage != self.modifiedImage)
        return YES;
    if(self.solarSlider.value != 0.5f || self.contrastSlider.value != 0.5f)
        return YES;
    return NO;
}

- (UIImage *)filteredImage {
    UIImage *filteredImage = [self.modifiedImage brightness:self.filterImageView.brightnessValues contrast:self.filterImageView.contrastValue];
    return filteredImage;
}

- (void)configureCaptureSession {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        AVCaptureSession *session = [[AVCaptureSession alloc] init];
        session.sessionPreset = AVCaptureSessionPresetPhoto;
        self.captureSession = session;
        // input
        self.backFacingCameraDeviceInput = [self getCameraInputByDevicePosition:AVCaptureDevicePositionBack];
        [session addInput:self.backFacingCameraDeviceInput];
        // output
        self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
        [self.stillImageOutput setOutputSettings:outputSettings];
        [session addOutput:self.stillImageOutput];
    }
}

- (AVCaptureDeviceInput *)getCameraInputByDevicePosition:(AVCaptureDevicePosition)pos {
    AVCaptureDeviceInput *result = nil;
    
    NSArray *devices = [AVCaptureDevice devices];
    for (AVCaptureDevice *device in devices) {
        if ([device hasMediaType:AVMediaTypeVideo]) {
            if ([device position] == pos) {
                result = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
                self.currentDevice = device;
                break;
            }
        }
    }
    
    return result;
}

- (void)changeCamera {
    [self.captureSession stopRunning];
    if(self.frontFacingCameraDeviceInput == nil) {
        [self.captureSession removeInput:self.backFacingCameraDeviceInput];
        self.backFacingCameraDeviceInput = nil;
        self.frontFacingCameraDeviceInput = [self getCameraInputByDevicePosition:AVCaptureDevicePositionFront];
        [self.captureSession addInput:self.frontFacingCameraDeviceInput];
    }
    else {
        [self.captureSession removeInput:self.frontFacingCameraDeviceInput];
        self.frontFacingCameraDeviceInput = nil;
        self.backFacingCameraDeviceInput = [self getCameraInputByDevicePosition:AVCaptureDevicePositionBack];
        [self.captureSession addInput:self.backFacingCameraDeviceInput];
    }
    [self.captureSession startRunning];
}

- (void)startShot {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        AVCaptureVideoPreviewLayer* previewLayer = [AVCaptureVideoPreviewLayer layerWithSession: self.captureSession];
        previewLayer.frame = self.cameraPreviewView.bounds;
        previewLayer.videoGravity= AVLayerVideoGravityResizeAspectFill;
        if(previewLayer.orientationSupported) {
            if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
                previewLayer.orientation = AVCaptureVideoOrientationLandscapeLeft;
            else 
                previewLayer.orientation = AVCaptureVideoOrientationLandscapeRight;
        }
        [self.cameraPreviewView.layer addSublayer:previewLayer];
        self.previewLayer = previewLayer;
        
        [self.captureSession startRunning];
    }
}

- (void)openCamera {
    [self startShot];
    [self hideCameraCoverAnimation];
}

#pragma mark - 
#pragma mark UI methods 

- (void)configureUI {
    [self configureCameraView];
    [self configureSlider];
    [self configureEffectShelfTableView];
}

+ (void)configureMotionsSlider:(UISlider *)slider {
    [slider setMinimumTrackImage:[UIImage imageNamed:@"transparent.png"] forState:UIControlStateNormal];
	[slider setMaximumTrackImage:[UIImage imageNamed:@"transparent.png"] forState:UIControlStateNormal];
    [slider setThumbImage:[UIImage imageNamed:@"slider_thumb.png"] forState:UIControlStateNormal];
	//[slider setThumbImage:[UIImage imageNamed:@"slider_thumb_highlight_blue.png"] forState:UIControlStateHighlighted];
}

- (void)configureSlider {
    [MotionsViewController configureMotionsSlider:self.solarSlider];
    [MotionsViewController configureMotionsSlider:self.contrastSlider];
}

- (void)configureCameraView {
    self.cameraPreviewBgView.layer.masksToBounds = YES;
    self.cameraPreviewBgView.layer.cornerRadius = 2.0f;
}

- (void)configureEffectShelfTableView {
    MotionsFilterTableViewController *vc = [[MotionsFilterTableViewController alloc] init];
    CGRect frame = vc.view.frame;
    frame.origin = CGPointMake(16, 394);
    vc.view.frame = frame;
    self.effectShelfViewController = vc;
    [self.editView insertSubview:self.effectShelfViewController.view belowSubview:self.effectShelfCoverImageView];
}

- (void)resetSliders {
    [self.solarSlider setValue:0.5f animated:YES];
    [self.contrastSlider setValue:0.5f animated:YES];
    [self.solarSlider setThumbImage:[UIImage imageNamed:@"slider_thumb.png"] forState:UIControlStateNormal];
    [self.contrastSlider setThumbImage:[UIImage imageNamed:@"slider_thumb.png"] forState:UIControlStateNormal];
}

- (void)showEditView {
    self.filterImageView.hidden = NO;
    [self.filterImageView initializeParameter];
    [self configureFilterImageView:self.originImage];
    
    [self showEditViewAnimation];
    [self.previewLayer removeFromSuperlayer];
    [self.captureSession stopRunning];
    [self hideCameraCoverAnimation];
}

#pragma mark -
#pragma mark Animation

- (void)showEditViewAnimation {
    [UIView animateWithDuration:0.3f animations:^{
        CGRect newFrame = self.shotView.frame;
        newFrame.origin.x = 1024;
        self.shotView.frame = newFrame;
        self.editView.frame = newFrame;
    } completion:^(BOOL finished) {
        self.editView.hidden = NO;
        self.capturedImageEditView.hidden = NO;
        self.capturedImageEditView.alpha = 0;
        [UIView animateWithDuration:0.3f animations:^{
            CGRect newFrame = self.editView.frame;
            newFrame.origin.x = 1024 - newFrame.size.width;
            self.editView.frame = newFrame;
            self.capturedImageEditView.alpha = 1;
        } completion:^(BOOL finished) {
        }];
    }];
}

- (void)showShotViewAnimation {
    self.capturedImageEditView.alpha = 1;
    [self showCameraCoverAnimation];
    [UIView animateWithDuration:0.3f animations:^{
        CGRect newFrame = self.editView.frame;
        newFrame.origin.x = 1024;
        self.editView.frame = newFrame;
        self.shotView.frame = newFrame;
        
        self.capturedImageEditView.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3f animations:^{
            CGRect newFrame = self.shotView.frame;
            newFrame.origin.x = 1024 - newFrame.size.width;
            self.shotView.frame = newFrame;
        } completion:^(BOOL finished) {
            [self.captureSession startRunning];
            [self.cameraPreviewView.layer addSublayer:self.previewLayer];
            self.filterImageView.hidden = YES;
            [self hideCameraCoverAnimation];
        }];
    }];
}

- (void)showCameraCoverAnimationWithCompletion:(void (^)(void))cmpl {
    self.view.userInteractionEnabled = NO;
    self.cameraStatusLEDButton.selected = NO;
    [UIView animateWithDuration:0.2f animations:^{
        CGRect frame = self.cameraCoverImageView.frame;
        frame.origin.y = 0;
        self.cameraCoverImageView.frame = frame;
    } completion:^(BOOL finished) {
        self.view.userInteractionEnabled = YES;
        if(cmpl)
            cmpl();
    }];
}

- (void)showCameraCoverAnimation {
    [self showCameraCoverAnimationWithCompletion:nil];
}

- (void)hideCameraCoverAnimation {
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.5f animations:^{
        CGRect frame = self.cameraCoverImageView.frame;
        frame.origin.y = 0 - frame.size.height;
        self.cameraCoverImageView.frame = frame;
    } completion:^(BOOL finished) {
        self.view.userInteractionEnabled = YES;
        self.cameraStatusLEDButton.selected = YES;
    }];
}

- (void)semiTransparentEditViewForCropAnimation {
    [UIView animateWithDuration:0.3f animations:^{
        for(UIView *subview in self.editView.subviews) {
            if(subview.tag != 1001) {
                subview.alpha = 0.2f;
                subview.userInteractionEnabled = NO;
            }
        }
    }];
}

- (void)opaqueEditViewAnimation {
    [UIView animateWithDuration:0.3f animations:^{
        for(UIView *subview in self.editView.subviews) {
            subview.alpha = 1;
        }
    } completion:^(BOOL finished) {
        for(UIView *subview in self.editView.subviews) {
            if([subview isMemberOfClass:[UIView class]])
                subview.userInteractionEnabled = YES;
        }
    }];
}

#pragma mark - 
#pragma mark Process image methods

- (void)configureFilterImageView:(UIImage *)image {
    UIImage *aspectFillImage = [image imageCroppedToFitSize:self.filterImageView.frame.size];
    NSLog(@"filter image width:%f, height:%f", image.size.width, image.size.height);
    [self.filterImageView setImage:aspectFillImage];
    [self.filterImageView setNeedsDisplay];
}

- (void)configureEditImage:(UIImage *)image {
    image = [image rotateAdjustImage];
    self.capturedImageView.image = image;
    self.originImage = image;
    self.modifiedImage = image;
    NSLog(@"origin image width:%f, height:%f", image.size.width, image.size.height);
}

- (void)configureShotImage:(UIImage *)image {
    UIImageOrientation imageOrientation;
    if(self.backFacingCameraDeviceInput) {
        imageOrientation = self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ? UIImageOrientationDown : UIImageOrientationUp;
    } else {
        imageOrientation = self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ? UIImageOrientationUpMirrored : UIImageOrientationDownMirrored;
    }
    
    image = [[UIImage alloc] initWithCGImage:image.CGImage scale:1.0f orientation:imageOrientation];
    [self configureEditImage:image];
}

#pragma mark - 
#pragma mark IBActions

- (IBAction)didClickCancelButton:(UIButton *)sender {
    [self.delegate motionViewControllerDidCancel];
}

- (IBAction)didChangeSlider:(UISlider *)sender {
    if(sender.value < 0.49f) {
        [sender setThumbImage:[UIImage imageNamed:@"slider_thumb_highlight_yellow.png"] forState:UIControlStateNormal];
    }
    else if(sender.value > 0.51f) {
        [sender setThumbImage:[UIImage imageNamed:@"slider_thumb_highlight_blue.png"] forState:UIControlStateNormal];
    }
    else {
        [sender setThumbImage:[UIImage imageNamed:@"slider_thumb.png"] forState:UIControlStateNormal];
    }
    if(sender == self.solarSlider) {
        float value = sender.value * 2 - 1;
        value = value > 0 ? value / 5 : value / 2;
        self.filterImageView.brightnessValues = value;
    }
    else if(sender == self.contrastSlider) {
        float value = sender.value > 0.5 ? (sender.value - 0.5) * 6 + 1 : sender.value * 2;
        value = value > 1 ? (value - 1) / 5 + 1 : 1 - (1 - value) / 5;
        self.filterImageView.contrastValue = value;
    }
    [self.filterImageView setNeedsDisplay];
}

- (IBAction)didClickShotButton:(UIButton *)sender {
    [self showCameraCoverAnimation];
	AVCaptureConnection *videoConnection = nil;
	for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
		for (AVCaptureInputPort *port in [connection inputPorts]) {
			if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
				videoConnection = connection;
				break;
			}
		}
		if (videoConnection) { break; }
	}
    
    if(!videoConnection) {
        NSLog(@"no videoConnection");
        return;
    }
    
    if(!self.stillImageOutput) {
        NSLog(@"no stillImageOutput");
        return;
    }
    
	[self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        if(!error) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            [self configureShotImage:image];
            [self showEditView];
        }
        else {
            NSLog(@"error:%@", error.localizedDescription);
        }
    }];
}

- (IBAction)didClickBackToShotButton:(UIButton *)sender {
    [self showShotViewAnimation];
    [self resetSliders];
}

- (IBAction)didClickChangeCameraButton:(UIButton *)sender {
    sender.userInteractionEnabled = NO;
    [self showCameraCoverAnimationWithCompletion:^{
        [self changeCamera];
        [self hideCameraCoverAnimation];
        sender.userInteractionEnabled = YES;
    }];
}

- (IBAction)didClickCropButton:(UIButton *)sender {
    [self semiTransparentEditViewForCropAnimation];
    self.cropButton.userInteractionEnabled = NO;
    self.finishCropButton.userInteractionEnabled = NO;
    
    self.cropButton.hidden = YES;
    self.finishCropButton.hidden = NO;
    
    
    self.cropImageViewController = [[CropImageViewController alloc] initWithImage:self.modifiedImage filteredImage:self.filteredImage];
    self.cropImageViewController.view.frame = self.filterImageView.frame;
    [self.cameraPreviewBgView insertSubview:self.cropImageViewController.view aboveSubview:self.filterImageView];
    self.cropImageViewController.delegate = self;
    
    [self.finishCropButton addTarget:self.cropImageViewController action:@selector(didClickFinishCropButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.cropImageViewController zoomInFromCenter:self.filterImageView.center withScaleFactor:self.capturedImageView.contentScaleFactor completion:^{
        self.finishCropButton.userInteractionEnabled = YES;
    }];
    
    [self.cropImageViewController.editBarView fadeIn];
    [self.capturedImageEditView fadeOut];
}

- (IBAction)didClickRevertButton:(UIButton *)sender {
    if(!self.isDirty) 
        return;
    
    [self resetSliders];
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithFrame:self.filterImageView.frame];
    tempImageView.image = self.filteredImage;
    tempImageView.contentMode = UIViewContentModeScaleAspectFill;
    [tempImageView setNeedsLayout];
    [self.cameraPreviewBgView insertSubview:tempImageView aboveSubview:self.filterImageView];
    
    self.capturedImageView.image = self.originImage;
    self.modifiedImage = self.originImage;
    [self configureFilterImageView:self.originImage];
    [self.filterImageView initializeParameter];
    
    [UIView animateWithDuration:0.3f animations:^{
        tempImageView.alpha = 0;
    } completion:^(BOOL finished) {
        [tempImageView removeFromSuperview];
    }];
}

- (IBAction)didClickPickImageButton:(UIButton *)sender {
    [self showCameraCoverAnimationWithCompletion:^{
        UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
        ipc.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
        ipc.delegate = self;
        ipc.allowsEditing = NO;
        
        UIPopoverController *pc = [[UIPopoverController alloc] initWithContentViewController:ipc];
        self.popoverController = pc;
        pc.delegate = self;
        [pc presentPopoverFromRect:sender.bounds inView:sender
          permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }];
}

- (IBAction)didClickFinishEditButton:(UIButton *)sender {
    [self.delegate motionViewControllerDidFinish:self.modifiedImage];    
}

#pragma mark -
#pragma mark MotionsCapturePreview delegate 

- (void)didCreateInterestPoint:(CGPoint)focusPoint {
    if([self.currentDevice lockForConfiguration:nil] == NO)
        return;
    if(self.currentDevice.focusPointOfInterestSupported) {
        NSLog(@"focusPointOfInterestSupported");
        [self.currentDevice setFocusPointOfInterest:focusPoint];
        if([self.currentDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [self.currentDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            NSLog(@"AVCaptureFocusModeContinuousAutoFocus");
        }
    }
    else if(self.currentDevice.exposurePointOfInterestSupported) {
        NSLog(@"exposurePointOfInterestSupported");
        [self.currentDevice setExposurePointOfInterest:focusPoint];
        if([self.currentDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [self.currentDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            NSLog(@"AVCaptureExposureModeContinuousAutoExposure");
        }
    }
    [self.currentDevice unlockForConfiguration];
}

#pragma mark -
#pragma mark CropImageViewController delegate

- (void)configureCropImageViewControllerTransition {
    [self opaqueEditViewAnimation];
    
    self.cropButton.userInteractionEnabled = NO;
    self.finishCropButton.userInteractionEnabled = NO;
    
    self.cropButton.hidden = NO;
    self.finishCropButton.hidden = YES;
    
    [self.finishCropButton removeTarget:self.cropImageViewController action:@selector(didClickFinishCropButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.cropImageViewController.editBarView fadeOut];
    [self.capturedImageEditView fadeIn];
    
    [self.cropImageViewController zoomOutToCenter:self.filterImageView.center withScaleFactor:self.capturedImageView.contentScaleFactor completion:^{
        [self.cropImageViewController.view removeFromSuperview];
        self.cropImageViewController = nil;
        self.cropButton.userInteractionEnabled = YES;
    }];
}

- (void)cropImageViewControllerDidFinishCrop:(UIImage *)image {
    [self configureFilterImageView:image];
    self.modifiedImage = image;
    self.capturedImageView.image = image;
    [self configureCropImageViewControllerTransition];
}

- (void)cropImageViewControllerDidCancelCrop {
    [self configureCropImageViewControllerTransition];
}

#pragma mark -
#pragma mark UIImagePickerController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self.popoverController dismissPopoverAnimated:YES];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self configureEditImage:image];
    [self showEditView];
    self.popoverController = nil;
}

#pragma mark -
#pragma mark UIPopoverController delegate 

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self hideCameraCoverAnimation];
    self.popoverController = nil;
}

@end
