//
//  MotionsShootViewController.m
//  VCard
//
//  Created by 王 紫川 on 12-6-25.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "MotionsShootViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Addition.h"
#import "UIView+Addition.h"
#import "UIApplication+Addition.h"

@interface MotionsShootViewController ()

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) AVCaptureDeviceInput *backFacingCameraDeviceInput;
@property (nonatomic, strong) AVCaptureDeviceInput *frontFacingCameraDeviceInput;
@property (nonatomic, strong) AVCaptureDevice *currentDevice;
@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, strong) UIImage *capturedImage;

@end

@implementation MotionsShootViewController

@synthesize delegate = _delegate;
@synthesize cameraStatusLEDButton = _cameraStatusLEDButton;
@synthesize cameraPreviewView = _cameraPreviewView;
@synthesize shootButton = _shootButton;
@synthesize pickImageButton = _pickImageButton;
@synthesize shootAccessoryView = _shootAccessoryView;

@synthesize captureSession = _captureSession;
@synthesize previewLayer = _previewLayer;
@synthesize stillImageOutput = _stillImageOutput;
@synthesize backFacingCameraDeviceInput = _backFacingCameraDeviceInput;
@synthesize frontFacingCameraDeviceInput = _frontFacingCameraDeviceInput;
@synthesize currentDevice = _currentDevice;
@synthesize popoverController = _pc;
@synthesize capturedImage = _capturedImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self configureCaptureSession];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configureCameraPreviewView];
}

- (void)viewDidUnload {
    self.cameraPreviewView = nil;
    self.cameraStatusLEDButton = nil;
    self.pickImageButton = nil;
    self.shootButton = nil;
    self.shootAccessoryView = nil;
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated {
    [self startShoot];
    [(NSObject *)self.delegate performSelector:@selector(shootViewControllerWillBecomeActiveWithCompletion:) withObject:nil afterDelay:0.1f];    
}

- (void)loadViewControllerWithInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    [self.popoverController dismissPopoverAnimated:YES];
    [super loadViewControllerWithInterfaceOrientation:interfaceOrientation];
}

#pragma mark - Logic methods

- (void)configureEditImage:(UIImage *)image {
    self.capturedImage = [image motionsAdjustImage];
}

- (void)configureShootImage:(UIImage *)image {
    UIImageOrientation imageOrientation;
    if(self.backFacingCameraDeviceInput) {
        switch ([UIApplication sharedApplication].statusBarOrientation) {
            case UIInterfaceOrientationLandscapeLeft:
                imageOrientation = UIImageOrientationDown;
                break;
            case UIInterfaceOrientationLandscapeRight:
                imageOrientation = UIImageOrientationUp;
                break;
            case UIDeviceOrientationPortrait:
                imageOrientation = UIImageOrientationRight;
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                imageOrientation = UIImageOrientationLeft;
                break;
            default:
                break;
        }
    } else {
        switch ([UIApplication sharedApplication].statusBarOrientation) {
            case UIInterfaceOrientationLandscapeLeft:
                imageOrientation = UIImageOrientationUpMirrored;
                break;
            case UIInterfaceOrientationLandscapeRight:
                imageOrientation = UIImageOrientationDownMirrored;
                break;
            case UIDeviceOrientationPortrait:
                imageOrientation = UIImageOrientationLeftMirrored;
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                imageOrientation = UIImageOrientationRightMirrored;
                break;
            default:
                break;
        }
    }
    self.capturedImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:1.0f orientation:imageOrientation];
    [self configureEditImage:self.capturedImage];
}

- (void)configurePreviewLayerOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if(self.previewLayer.orientationSupported) {
        if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
            self.previewLayer.orientation = AVCaptureVideoOrientationLandscapeLeft;
        else if(interfaceOrientation == UIInterfaceOrientationLandscapeRight)
            self.previewLayer.orientation = AVCaptureVideoOrientationLandscapeRight;
        else if(interfaceOrientation == UIInterfaceOrientationPortrait)
            self.previewLayer.orientation = AVCaptureVideoOrientationPortrait;
        else if(interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
            self.previewLayer.orientation = AVCaptureVideoOrientationPortraitUpsideDown;
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
        NSDictionary *outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG};
        [self.stillImageOutput setOutputSettings:outputSettings];
        [session addOutput:self.stillImageOutput];
    }
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
    //[self.captureSession startRunning];
    [self startShoot];
}

- (void)startShoot {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        AVCaptureVideoPreviewLayer* previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
        previewLayer.frame = self.cameraPreviewView.bounds;
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        //To Do : why should I omit this?
        //[self.previewLayer removeFromSuperlayer];
        self.previewLayer = previewLayer;
        
        [self configurePreviewLayerOrientation:[UIApplication sharedApplication].statusBarOrientation];
        [self.cameraPreviewView.layer addSublayer:previewLayer];
        [self.cameraPreviewView fadeIn];
        [self.captureSession startRunning];
    }
}

- (void)stopShoot {
    [self.captureSession stopRunning];
}

#pragma mark - UI methods

- (void)configureCameraPreviewView {
    self.cameraPreviewView.layer.masksToBounds = YES;
    self.cameraPreviewView.layer.cornerRadius = 2.0f;
}

#pragma mark - Animations

- (void)setShowShootAccessoriesFrame {
    CGRect frame = self.shootAccessoryView.frame;
    if(self.isCurrentOrientationLandscape) {
        frame.origin.x = 1024 - frame.size.width;
        frame.origin.y = 0;
    } else {
        frame.origin.x = 0;
        frame.origin.y = 1004 - frame.size.height;
    }
    self.shootAccessoryView.frame = frame;
}

- (void)setHideShootAccessoriesFrame {
    CGRect frame = self.shootAccessoryView.frame;
    if(self.isCurrentOrientationLandscape) {
        frame.origin.x = 1024;
        frame.origin.y = 0;
    } else {
        frame.origin.x = 0;
        frame.origin.y = 1004;
    }
    self.shootAccessoryView.frame = frame;
}

- (void)hideShootAccessoriesAnimationWithCompletion:(void (^)(void))completion {
    [self setShowShootAccessoriesFrame];
    [UIView animateWithDuration:0.3f animations:^{
        [self setHideShootAccessoriesFrame];
    } completion:^(BOOL finished) {
        if(completion)
            completion();
    }];
}

- (void)showShootAccessoriesAnimationWithCompletion:(void (^)(void))completion {
    [self setHideShootAccessoriesFrame];
    [UIView animateWithDuration:0.3f animations:^{
        [self setShowShootAccessoriesFrame];
    } completion:^(BOOL finished) {
        if(completion)
            completion();
    }];
}

#pragma mark - IBActions

- (IBAction)didClickShootButton:(UIButton *)sender {
    self.view.userInteractionEnabled = NO;
    
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
        return;
    }
    
    if(!self.stillImageOutput) {
        return;
    }
    
    BlockWeakSelf weakSelf = self;
    [self.delegate shootViewControllerWillBecomeInactiveWithCompletion:^{
        [weakSelf.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
            if(!error) {
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    UIImage *image = [[UIImage alloc] initWithData:imageData];
                    [weakSelf configureShootImage:image];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.delegate shootViewController:weakSelf didCaptureImage:weakSelf.capturedImage fromLibrary:NO];
                    });
                });
            }
        }];
    }];
}

- (IBAction)didClickChangeCameraButton:(UIButton *)sender {
    sender.userInteractionEnabled = NO;
    BlockARCWeakSelf weakSelf = self;
    [self.delegate shootViewControllerWillBecomeInactiveWithCompletion:^{
        [weakSelf changeCamera];
        [weakSelf.delegate shootViewControllerWillBecomeActiveWithCompletion:^{
            sender.userInteractionEnabled = YES;
        }];
    }];
}

- (IBAction)didClickPickImageButton:(UIButton *)sender {
    BlockARCWeakSelf weakSelf = self;
    [self.delegate shootViewControllerWillBecomeInactiveWithCompletion:^{
        UIPopoverController *pc =  [UIApplication showAlbumImagePickerFromButton:sender delegate:weakSelf];
        weakSelf.popoverController = pc;
    }];
}

#pragma mark -
#pragma mark MotionsCapturePreview delegate 

- (void)didCreateInterestPoint:(CGPoint)focusPoint {
    if([self.currentDevice lockForConfiguration:nil] == NO)
        return;
    if(self.currentDevice.focusPointOfInterestSupported) {
        [self.currentDevice setFocusPointOfInterest:focusPoint];
        if([self.currentDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [self.currentDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
    }
    else if(self.currentDevice.exposurePointOfInterestSupported) {
        [self.currentDevice setExposurePointOfInterest:focusPoint];
        if([self.currentDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [self.currentDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
    }
    [self.currentDevice unlockForConfiguration];
}

#pragma mark -
#pragma mark UIImagePickerController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self.popoverController dismissPopoverAnimated:YES];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.popoverController = nil;
    [self configureEditImage:image];
    [self.delegate shootViewController:self didCaptureImage:self.capturedImage fromLibrary:YES];
}

#pragma mark -
#pragma mark UIPopoverController delegate 

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    [self.delegate shootViewControllerWillBecomeActiveWithCompletion:nil];
    self.popoverController = nil;
}

@end
