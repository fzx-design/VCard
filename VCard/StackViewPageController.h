//
//  StackViewPageController.h
//  VCard
//
//  Created by 海山 叶 on 12-5-26.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@interface StackViewPageController : CoreDataViewController {
    NSInteger _pageIndex;
    
}

@property (nonatomic, assign) NSInteger pageIndex;


@end
