//
//  SettingBrightnessViewController.m
//  VCard
//
//  Created by 王 紫川 on 12-7-14.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "SettingBrightnessViewController.h"

#define kDefaultSettingOptionDataSourceKey @"DefaultSettingOptionDataSourceKey"

@interface SettingBrightnessViewController ()

@end

@implementation SettingBrightnessViewController

- (id)initWithOptionKey:(NSString *)key {
    self = [super init];
    if(self) {
        
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"SettingRootViewController" bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

#pragma mark -
#pragma mark WTGroupTableViewController methods to overwrite

- (NSString *)customCellClassName {
    return @"SettingBrightnessCell";
}

- (void)configureDataSource {
    [self.dataSourceDictionary setObject:[NSArray arrayWithObject:kDefaultSettingOptionDataSourceKey] forKey:kDefaultSettingOptionDataSourceKey];
    [self.dataSourceIndexArray addObject:kDefaultSettingOptionDataSourceKey];
}

@end
