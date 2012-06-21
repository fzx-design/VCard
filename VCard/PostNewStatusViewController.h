//
//  PostNewStatusViewController.h
//  VCard
//
//  Created by 紫川 王 on 12-6-21.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PostViewController.h"

@interface PostNewStatusViewController : PostViewController <CLLocationManagerDelegate> {
    BOOL _located;
    CLLocationCoordinate2D _location2D;
}

@end
