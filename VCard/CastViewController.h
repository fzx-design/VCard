//
//  CastViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-4-18.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaterflowView.h"
#import "CoreDataTableViewController.h"

@interface CastViewController : CoreDataTableViewController <WaterflowViewDelegate,WaterflowViewDatasource,UIScrollViewDelegate> {
    
    WaterflowView *_waterflowView;
}

@property(nonatomic, strong) IBOutlet WaterflowView *waterflowView;

@end
