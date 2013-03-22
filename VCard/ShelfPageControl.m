//
//  ShelfPageControl.m
//  VCard
//
//  Created by 海山 叶 on 12-7-5.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "ShelfPageControl.h"
#import "UIView+Resize.h"

@interface ShelfPageControl (Private)
- (void) updateDots;
@end


@implementation ShelfPageControl

/** override to update dots */
- (void) setCurrentPage:(NSInteger)currentPage
{
    [super setCurrentPage:currentPage];
    
    // update dot views
    [self updateDots];
}

/** override to update dots */
- (void) updateCurrentPageDisplay
{
    [super updateCurrentPageDisplay];
    
    // update dot views
    [self updateDots];
}

/** Override setImageNormal */
- (void) setImageNormal:(UIImage*)image
{
    _imageNormal = image;
    [self updateDots];
}

/** Override setImageCurrent */
- (void) setImageCurrent:(UIImage*)image
{
    _imageCurrent = image;
    
    // update dot views
    [self updateDots];
}

/** Override to fix when dots are directly clicked */
- (void) endTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event 
{
    [super endTrackingWithTouch:touch withEvent:event];
    
    [self updateDots];
}

#pragma mark - (Private)

- (void)updateDots
{
    if (_imageCurrent || _imageNormal) {
        // Get subviews
        NSArray* dotViews = self.subviews;
        
        UIImageView *dot = [dotViews objectAtIndex:0];
        dot.image = self.currentPage == 0 ? _imageSettingHighlight : _imageSetting;
        [dot resetSize:CGSizeMake(12.0, 12.0)];
        
        for(int i = 1; i < dotViews.count; ++i) {
            UIImageView* dot = [dotViews objectAtIndex:i];
            dot.image = (i == self.currentPage) ? _imageCurrent : _imageNormal;
            [dot resetSize:CGSizeMake(12.0, 12.0)];
        }
    }
}

@end