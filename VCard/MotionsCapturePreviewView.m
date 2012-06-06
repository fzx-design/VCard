//
//  MotionsCapturePreviewView.m
//  VCard
//
//  Created by 紫川 王 on 12-4-13.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "MotionsCapturePreviewView.h"

@interface MotionsCapturePreviewView() 

@property (nonatomic, strong) UIImageView *focusImageView;

@end

@implementation MotionsCapturePreviewView

@synthesize focusImageView = _focusImageView;

@synthesize delegate = _delegate;

- (void)awakeFromNib {
    // Initialization code
    self.focusImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"motions_capture_focus.png"]];
    self.focusImageView.hidden = YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)showFocusImageView {
    [self addSubview:self.focusImageView];
    self.focusImageView.hidden = NO;
    self.focusImageView.alpha = 0;
    self.focusImageView.transform = CGAffineTransformMakeScale(2.0, 2.0);
    [UIView animateWithDuration:0.2f animations:^{
        self.focusImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        self.focusImageView.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveLinear animations:^{
            self.focusImageView.alpha = 0;
        } completion:^(BOOL finished) {
            self.focusImageView.hidden = YES;
            [self.focusImageView removeFromSuperview];
        }];
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(self.focusImageView.hidden == NO)
        return;
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    self.focusImageView.center = point;
    [self showFocusImageView];
    
    CGPoint focusPoint = CGPointMake(point.x / self.frame.size.width, 1 - point.y / self.frame.size.height);
    [self.delegate didCreateInterestPoint:focusPoint];
}
@end
