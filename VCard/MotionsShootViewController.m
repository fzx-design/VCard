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

@interface MotionsShootViewController ()

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) AVCaptureDeviceInput *backFacingCameraDeviceInput;
@property (nonatomic, strong) AVCaptureDeviceInput *frontFacingCameraDeviceInput;
@property (nonatomic, strong) AVCaptureDevice *currentDevice;
@property (nonatomic, strong) UIPopoverController *popoverController;

@end

@implementation MotionsShootViewController

@synthesize delegate = _delegate;
@synthesize cameraStatusLEDButton = _cameraStatusLEDButton;
@synthesize cameraPreviewView = _cameraPreviewView;
@synthesize shootButton = _shootButton;
@synthesize pickImageButton = _pickImageButton;

@synthesize captureSession = _captureSession;
@synthesize previewLayer = _previewLayer;
@synthesize stillImageOutput = _stillImageOutput;
@synthesize backFacingCameraDeviceInput = _backFacingCameraDeviceInput;
@synthesize frontFacingCameraDeviceInput = _frontFacingCameraDeviceInput;
@synthesize currentDevice = _currentDevice;
@synthesize popoverController = _pc;

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
    [super viewDidUnload];
    self.cameraPreviewView = nil;
    self.cameraStatusLEDButton = nil;
    self.pickImageButton = nil;
    self.shootButton = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [self startShoot];
    [self.delegate shootViewControllerWillBecomeActiveWithCompletion:nil];
}

#pragma mark - Logic methods

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
        NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
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
    [self.captureSession startRunning];
}

- (void)startShoot {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        AVCaptureVideoPreviewLayer* previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
        previewLayer.frame = self.cameraPreviewView.bounds;
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.previewLayer = previewLayer;
        [self configurePreviewLayerOrientation:[[UIDevice currentDevice] orientation]];
        [self.cameraPreviewView.layer addSublayer:previewLayer];
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

#pragma mark - IBActions 

- (IBAction)didClickShootButton:(UIButton *)sender {
    self.view.userInteractionEnabled = NO;
    [self.delegate shootViewControllerWillBecomeInactiveWithCompletion:nil];
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
            [self.delegate shootViewController:self didCaptureImage:image];
        }
        else {
            NSLog(@"error:%@", error.localizedDescription);
        }
    }];
}

- (IBAction)didClickChangeCameraButton:(UIButton *)sender {
    sender.userInteractionEnabled = NO;
    [self.delegate shootViewControllerWillBecomeInactiveWithCompletion:^{
        [self changeCamera];
        [self.delegate shootViewControllerWillBecomeActiveWithCompletion:nil];
        sender.userInteractionEnabled = YES;
    }];
}

- (IBAction)didClickPickImageButton:(UIButton *)sender {
    [self.delegate shootViewControllerWillBecomeInactiveWithCompletion:^{
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
#pragma mark UIImagePickerController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self.popoverController dismissPopoverAnimated:YES];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.popoverController = nil;
    [self.delegate shootViewController:self didCaptureImage:image];
}

#pragma mark -
#pragma mark UIPopoverController delegate 

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    [self.delegate shootViewControllerWillBecomeActiveWithCompletion:nil];
    self.popoverController = nil;
}

@end
