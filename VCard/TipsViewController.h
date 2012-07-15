//
//  TipsViewControllerler.h
//  VCard
//
//  Created by 王 紫川 on 12-7-12.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShelfPageControl.h"

typedef enum {
    TipsViewControllerTypeStack,
    TipsViewControllerTypeShelf,
} TipsViewControllerType;

@interface TipsViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIView *tipsView;
@property (nonatomic, strong) IBOutlet UILabel *tipsLabel;

- (id)initWithType:(TipsViewControllerType)type;

- (void)show;

@end
