//
//  UnreadIndicatorView.h
//  VCard
//
//  Created by 海山 叶 on 12-6-29.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UnreadIndicatorButton.h"

@interface UnreadIndicatorView : UIView {
    int _currentIndicatorCount;
}

- (void)addNewIndicator:(UnreadIndicatorButton *)indicator;
- (void)removeIndicator:(UnreadIndicatorButton *)indicator;

@end
