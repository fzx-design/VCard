//
//  ErrorIndicatorViewControllerler.m
//  VCard
//
//  Created by 王 紫川 on 12-7-12.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "ErrorIndicatorViewController.h"
#import "UIApplication+Addition.h"
#import "UIView+Resize.h"
#import "UIView+Addition.h"

static ErrorIndicatorViewController *errorIndicatorInstance = nil;

#define SHELF_TIPS_TEXT @"向右滑动可以打开快速阅读设置"
#define STACK_TIPS_TEXT @"将分页划出屏幕以关闭" 

#define AUTOMATIC_DISMISS_VIEW_DELAY    2.0f
#define DISMISS_VIEW_ANIMATION_DURATION 2.0f

@interface ErrorIndicatorViewController () {
    ErrorIndicatorViewControllerType _controllerType;
    NSString *_contentText;
    BOOL _showViewAnimated;
}

@end

@implementation ErrorIndicatorViewController

@synthesize errorBgView = _errorBgView;
@synthesize errorImageView = _errorImageView;
@synthesize errorLabel = _errorLabel;
@synthesize refreshIndicator = _refreshIndicator;

+ (ErrorIndicatorViewController *)showErrorIndicatorWithType:(ErrorIndicatorViewControllerType)type
                                                 contentText:(NSString *)contentText {
    return [ErrorIndicatorViewController showErrorIndicatorWithType:type contentText:contentText animated:YES];
}

+ (ErrorIndicatorViewController *)showErrorIndicatorWithType:(ErrorIndicatorViewControllerType)type
                                                 contentText:(NSString *)contentText
                                                    animated:(BOOL)animated {
    if(!errorIndicatorInstance) {
        errorIndicatorInstance = [[ErrorIndicatorViewController alloc] initWithType:type contentText:contentText showViewAnimated:animated];
        [errorIndicatorInstance.view resetOriginY:20];
        
        [[UIApplication sharedApplication].rootViewController.view addSubview:errorIndicatorInstance.view];
        return errorIndicatorInstance;
    } else {
        return nil;
    }
}

- (id)initWithType:(ErrorIndicatorViewControllerType)type
       contentText:(NSString *)contentText
  showViewAnimated:(BOOL)animated{
    self = [super init];
    if(self) {
        _controllerType = type;
        _contentText = contentText;
        _showViewAnimated = animated;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view resetSize:[UIApplication sharedApplication].screenSize];
    [self configureUI];
    [self show];
}

- (void)viewDidUnload
{
    self.errorBgView = nil;
    self.errorImageView = nil;
    self.errorLabel = nil;
    self.refreshIndicator = nil;
    [super viewDidUnload];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

#pragma mark - Logic methods 

- (void)automaticDismissView {
    [self dismissViewAnimated:YES completion:nil];
}

#pragma mark - UI methods

- (void)configureUI {
    NSString *defaultContentText = nil;
    self.refreshIndicator.hidden = YES;
    NSString *errorImageName = nil;
    if(_controllerType == ErrorIndicatorViewControllerTypeConnectFailure) {
        defaultContentText = @"网络错误";
        errorImageName = @"icon_connection_error";
    } else if(_controllerType == ErrorIndicatorViewControllerTypeLoading) {
        defaultContentText = @"正在通信...";
        errorImageName = nil;
        self.refreshIndicator.hidden = NO;
        self.errorImageView.hidden = YES;
        [self.refreshIndicator setType:RefreshIndicatorViewTypeLargeWhite];
        [self.refreshIndicator startLoadingAnimation];
    } else if(_controllerType == ErrorIndicatorViewControllerTypeProcedureFailure) {
        defaultContentText = @"操作失败";
        errorImageName = @"icon_regular_error";
    } else if(_controllerType == ErrorIndicatorViewControllerTypeProcedureSuccess) {
        defaultContentText = @"操作成功";
        errorImageName = @"icon_complete";
    }
    self.errorImageView.image = [UIImage imageNamed:errorImageName];
    self.errorLabel.text = _contentText ? _contentText : defaultContentText;

}

- (void)show {
    void (^completionBlock)(void) = ^{
        if(_controllerType != ErrorIndicatorViewControllerTypeLoading) {
            [self performSelector:@selector(automaticDismissView) withObject:nil afterDelay:AUTOMATIC_DISMISS_VIEW_DELAY];
        }
    };
    if(_showViewAnimated)
        [self.view fadeInWithCompletion:^{
            completionBlock();
        }];
    else {
        completionBlock();
    }
}

- (void)dismissViewAnimated:(BOOL)animted completion:(void (^)(void))completion {
    
    BlockARCWeakSelf weakSelf = self;
    void (^completionBlock)(void) = ^{
        NSLog(@"dismiss error vc with type:%d", _controllerType);
        [weakSelf.view removeFromSuperview];
        errorIndicatorInstance = nil;
        if(completion)
            completion();
    };
    if(animted) {
        self.view.alpha = 1;
        [UIView animateWithDuration:DISMISS_VIEW_ANIMATION_DURATION animations:^{
            self.view.alpha = 0;
        } completion:^(BOOL finished) {
            completionBlock();
        }];
    }
    else {
        [self.view removeFromSuperview];
        completionBlock();
    }
}

@end
