//
//  RootViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-4-18.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CastViewController.h"
#import "CoreDataViewController.h"
#import "ShelfViewController.h"
#import "DetailImageViewController.h"
#import "SimpleTableViewController.h"

@interface RootViewController : CoreDataViewController <CastViewControllerDelegate> {
    CastViewController *_castViewController;
}

@property (nonatomic, strong) CastViewController *castViewController;
@property (nonatomic, strong) ShelfViewController *shelfViewController;
@property (nonatomic, strong) DetailImageViewController *detailImageViewController;
@property (nonatomic, strong) SimpleTableViewController *SimpleTableView;
@end
