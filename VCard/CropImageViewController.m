//
//  CropImageViewController.m
//  VCard
//
//  Created by 紫川 王 on 12-4-19.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "CropImageViewController.h"
#import "UIImageView+ContentScale.h"
#import "UIView+Addition.h"
#import "UIImage+ProportionalFill.h"
#import "UIImage+Addition.h"

@interface CropImageViewController ()

@property (nonatomic, strong) UIImage *filteredImage;
@property (nonatomic, strong) UIImage *originImage;

@end

@implementation CropImageViewController

@synthesize filteredImage = _filteredImage;
@synthesize originImage = _originImage;
@synthesize delegate = _delegate;
@synthesize cropImageBgView = _cropImageBgView;
@synthesize cropImageView = _cropImageView;
@synthesize editBarView = _editBarView;

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
    self.cropImageBgView.image = self.filteredImage;
    CGSize cropImageSize = CGSizeMake(self.cropImageBgView.contentScaleFactor * self.filteredImage.size.width, self.cropImageBgView.contentScaleFactor * self.filteredImage.size.height);
    [self.cropImageView setCropImageInitSize:cropImageSize center:self.cropImageBgView.center];
    self.cropImageView.bgImageView = self.cropImageBgView;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.cropImageBgView = nil;
    self.editBarView = nil;
    self.cropImageView = nil;
}

- (id)initWithImage:(UIImage *)image filteredImage:(UIImage *)filteredImage {
    self = [super init];
    if(self) {
        self.originImage = image;
        self.filteredImage = filteredImage;
    }
    return self;
}

- (void)zoomInFromCenter:(CGPoint)point withScaleFactor:(CGFloat)factor completion:(void (^)(void))completion{
    self.cropImageBgView.transform = CGAffineTransformMakeScale(factor / self.cropImageBgView.contentScaleFactor, factor / self.cropImageBgView.contentScaleFactor);
    CGPoint center = self.cropImageBgView.center;
    self.cropImageBgView.center = point;
    [self.cropImageView fadeIn];
    [UIView animateWithDuration:0.3f animations:^{
        self.cropImageBgView.transform = CGAffineTransformIdentity;
        self.cropImageBgView.center = center;
    } completion:^(BOOL finished) {
        if(completion)
            completion();
    }];
}

- (void)zoomOutToCenter:(CGPoint)point withScaleFactor:(CGFloat)factor completion:(void (^)(void))completion {
    [self.cropImageView fadeOut];
    [UIView animateWithDuration:0.3f animations:^{
        self.cropImageBgView.transform = CGAffineTransformMakeScale(factor / self.cropImageBgView.contentScaleFactor, factor / self.cropImageBgView.contentScaleFactor);
        self.cropImageBgView.center = point;
    } completion:^(BOOL finished) {
        if(completion)
            completion();
    }];
}

- (UIImage *)cropImage:(UIImage *)image {
    CGRect scaleFrame = self.cropImageView.cropImageRect;
    
    CGSize sizeBeforeRotate = image.size;
    CGFloat x = scaleFrame.origin.x;
    CGFloat y = scaleFrame.origin.y;
    CGFloat w = scaleFrame.size.width;
    CGFloat h = scaleFrame.size.height;
    CGPoint center = CGPointMake(sizeBeforeRotate.width / 2, sizeBeforeRotate.height / 2);
    
    image = [image imageRotatedByRadians:self.cropImageView.rotationFactor];
    CGSize sizeAfterRotate = image.size;
    CGPoint newCenter = CGPointMake(sizeAfterRotate.width / 2, sizeAfterRotate.height / 2);
    CGRect rotateFrame = CGRectMake(newCenter.x - (center.x - x), newCenter.y - (center.y - y), w, h);
    UIImage *result = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(image.CGImage, rotateFrame)];
    return result;
}

- (void)resetCropImageBgView {
    self.cropImageBgView.transform = CGAffineTransformIdentity;
    self.cropImageBgView.image = self.filteredImage;
    self.cropImageBgView.frame = self.cropImageView.cropEditRect;
}

#pragma mark -
#pragma mark IBActions

- (IBAction)didClickFinishCropButton:(UIButton *)sender {
    self.filteredImage = [self cropImage:self.filteredImage];
    self.originImage = [self cropImage:self.originImage];
    [self resetCropImageBgView];
    [self.delegate cropImageViewControllerDidFinishCrop:self.originImage];
}

- (IBAction)didClickCancelButton:(UIButton *)sender {
    [self.delegate cropImageViewControllerDidCancelCrop];
}

@end
