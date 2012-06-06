//
//  FilterImageView.m
//  VCard
//
//  Created by 紫川 王 on 12-4-18.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "FilterImageView.h"
#include <OpenGLES/EAGL.h>
#import <QuartzCore/QuartzCore.h>

@interface FilterImageView() 

@property (nonatomic, strong) CIImage *ciimage;
@property (nonatomic, strong) CIContext *coreImageContext;
@property (nonatomic, strong) CIFilter *filter;

@end

@implementation FilterImageView

@synthesize ciimage = _ciimage;
@synthesize brightnessValues = _brightnessValues;
@synthesize contrastValue = _contrastValue;
//@synthesize saturationValue = _saturationValue;
@synthesize coreImageContext = _coreImageContext;
@synthesize filter = _filter;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)initializeParameter {
    self.brightnessValues = 0;
    self.contrastValue = 1;
}

- (void)setImage:(UIImage *)image {
    //self.saturationValue = 1;
    self.ciimage = [[CIImage alloc] initWithImage:image];
}

- (void)didMoveToSuperview {
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"];
    self.filter = filter;
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    self.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    
    _coreImageContext = [CIContext contextWithEAGLContext:self.context]; 
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)drawImage {
    NSLog(@"draw filter image");
    [self.filter setDefaults];
    [self.filter setValue:self.ciimage forKey:@"inputImage"];
    [self.filter setValue:[NSNumber numberWithFloat:self.brightnessValues]
              forKey:@"inputBrightness"];
    [self.filter setValue:[NSNumber numberWithFloat:self.contrastValue]
              forKey:@"inputContrast"];
//    [self.filter setValue:[NSNumber numberWithFloat:self.saturationValue]
//               forKey:@"inputSaturation"];
    CIImage *outputImage = [self.filter outputImage];
    [_coreImageContext drawImage:outputImage atPoint:CGPointZero fromRect:outputImage.extent];
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)drawRect:(CGRect)rect {
    [self drawImage];
}

@end
