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
    ErrorIndicatorViewControllerTypePostSuccess,
} ErrorIndicatorViewControllerType;

@interface ErrorIndicatorViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIView *errorBgView;
@property (nonatomic, strong) IBOutlet UIImageView *errorImageView;
@property (nonatomic, strong) IBOutlet UILabel *errorLabel;
@property (nonatomic, strong) IBOutlet RefreshIndicatorView *refreshIndicator;

//只允许一个error indicator存在，超过一个的时候会返回nil。

+ (ErrorIndicatorViewController *)showErrorIndicatorWithType:(ErrorIndicatorViewControllerType)type
                                                 contentText:(NSString *)contentText;

+ (ErrorIndicatorViewController *)showErrorIndicatorWithType:(ErrorIndicatorViewControllerType)type
                                                 contentText:(NSString *)contentText
                                                    animated:(BOOL)animated;

- (void)dismissViewAnimated:(BOOL)animted completion:(void (^)(void))completion;

@end
