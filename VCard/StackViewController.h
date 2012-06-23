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

@interface StackViewController : CoreDataViewController <StackViewDelegate> {    
    StackView *_stackView;
    NSMutableArray *_controllerStack;
    
    __unsafe_unretained id<StackViewControllerDelegate> _delegate;
}

@property (nonatomic, strong) IBOutlet StackView *stackView;
@property (nonatomic, strong) NSMutableArray *controllerStack;

@property (nonatomic, assign) id<StackViewControllerDelegate> delegate;

- (void)insertStackPage:(StackViewPageController *)vc
                atIndex:(int)targetIndex
           withPageType:(StackViewPageType)pageType
        pageDescription:(NSString *)pageDescription;

- (void)addViewController:(StackViewPageController *)vc 
                  atIndex:(int)targetIndex;

@end
