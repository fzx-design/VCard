//
//  StackViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-5-26.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "StackView.h"

@interface StackViewController : CoreDataTableViewController {
    StackView *_stackView;
    NSMutableArray *_controllerStack;
}

@property (nonatomic, strong) StackView *stackView;
@property (nonatomic, strong) NSMutableArray *controllerStack;

- (void)addViewController:(UIViewController *)viewController;

@end
