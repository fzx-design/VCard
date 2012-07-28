//
//  StackViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-5-26.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "StackViewPageController.h"
#import "StackView.h"

@protocol StackViewControllerDelegate <NSObject>

- (void)clearStack;
- (void)stackViewScrolledWithOffset:(CGFloat)offset width:(CGFloat)width;

@end

@interface StackViewController : CoreDataViewController <StackViewDelegate>

@property (nonatomic, weak) IBOutlet StackView *stackView;
@property (nonatomic, strong) NSMutableArray *controllerStack;

@property (nonatomic, weak) id<StackViewControllerDelegate> delegate;

- (void)insertStackPage:(StackViewPageController *)vc
                atIndex:(int)targetIndex
           withPageType:(StackViewPageType)pageType
        pageDescription:(NSString *)pageDescription;

- (void)addViewController:(StackViewPageController *)vc 
                  atIndex:(int)targetIndex;
- (void)refresh;
- (void)deleteAllPages;
- (int)stackTopIndex;

@end
