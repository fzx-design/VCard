//
//  EmptyIndicatorViewController.h
//  VCard
//
//  Created by Gabriel Yeah on 12-8-2.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EmptyIndicatorViewControllerDelegate <NSObject>

- (void)didClickRefreshButton;

@end

@interface EmptyIndicatorViewController : UIViewController

@property (nonatomic, weak) id<EmptyIndicatorViewControllerDelegate> delegate;

- (IBAction)didClickRefreshButton:(UIButton *)sender;

@end
