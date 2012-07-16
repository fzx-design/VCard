//
//  ErrorIndicatorViewControllerler.h
//  VCard
//
//  Created by 王 紫川 on 12-7-12.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RefreshIndicatorView.h"

typedef enum {
    ErrorIndicatorViewControllerTypeConnectFailure,
    ErrorIndicatorViewControllerTypeLoading,
    ErrorIndicatorViewControllerTypePostFailure,
} ErrorIndicatorViewControllerType;

@interface ErrorIndicatorViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIView *errorBgView;
@property (nonatomic, strong) IBOutlet UIView *errorImageView;
@property (nonatomic, strong) IBOutlet UILabel *errorLabel;
@property (nonatomic, strong) IBOutlet RefreshIndicatorView *refreshIndicator;

- (id)initWithType:(ErrorIndicatorViewControllerType)type;

- (void)show;

@end
