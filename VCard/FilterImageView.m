//
//  FilterImageView.m
//  VCard
//
//  Created by 紫川 王 on 12-4-18.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "FilterImageView.h"
#import <OpenGLES/EAGL.h>
#import <QuartzCore/QuartzCore.h>

@interface FilterImageView() 

@property (nonatomic, strong) CIContext *coreImageContext;
@property (nonatomic, strong) CIFilter *highlightShadowAdjustFilter;

@end

@implementation FilterImageView

@synthesize processImage = _ciimage;
@synthesize shadowAmountValue = _shadowAmountValue;
@synthesize coreImageContext = _coreImageContext;
@synthesize highlightShadowAdjustFilter = _highlightShadowAdjustFilter;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initializeParameter];
    }
    return self;
}

- (void)initializeParameter {
    self.shadowAmountValue = 0;
}

- (void)setImage:(UIImage *)image {
    self.processImage = [[CIImage alloc] initWithImage:image];
}

- (void)didMoveToSuperview {
    CIFilter *filter = [CIFilter filterWithName:@"CIHighlightShadowAdjust"];
    self.highlightShadowAdjustFilter = filter;
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    self.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    
    self.coreImageContext = [CIContext contextWithEAGLContext:self.context];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)drawImage {
    [self.highlightShadowAdjustFilter setDefaults];
    [self.highlightShadowAdjustFilter setValue:self.processImage forKey:@"inputImage"];
    [self.highlightShadowAdjustFilter setValue:@(self.shadowAmountValue)
                               forKey:@"inputShadowAmount"];
    CIImage *outputImage = [self.highlightShadowAdjustFilter outputImage];
    
    [_coreImageContext drawImage:outputImage atPoint:CGPointZero fromRect:outputImage.extent];
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)drawRect:(CGRect)rect {
    [self drawImage];
}

@end
