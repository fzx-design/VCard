//
//  UIView+Addition.m
//  WeTongji
//
//  Created by 紫川 王 on 12-4-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIView+Addition.h"

@implementation UIView (Addition)

- (void)fadeIn {
    [self fadeInWithCompletion:nil];
}

- (void)fadeOut {
    [self fadeOutWithCompletion:nil];
}

- (void)fadeInWithCompletion:(void (^)(void))completion {
    self.alpha = 0;
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        if(completion)
            completion();
    }];
}

- (void)fadeOutWithCompletion:(void (^)(void))completion {
    self.alpha = 1;
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if(completion)
            completion();
    }];
}

- (void)transitionFadeIn {
    self.alpha = 0;
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationCurveLinear animations:^{
        self.alpha = 1;
    } completion:nil];
}

- (void)transitionFadeOut {
    self.alpha = 1;
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationCurveLinear animations:^{
        self.alpha = 0;
    } completion:nil];
}

@end
