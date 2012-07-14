//
//  SettingOptionViewController.m
//  VCard
//
//  Created by 王 紫川 on 12-7-14.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "SettingOptionViewController.h"
#import "NSUserDefaults+Addition.h"

#define kDefaultSettingOptionDataSourceKey @"DefaultSettingOptionDataSourceKey"

@interface SettingOptionViewController ()

@property (nonatomic, strong) SettingOptionInfo *optionInfo;

@end

@implementation SettingOptionViewController

@synthesize optionInfo = _optionInfo;

- (id)initWithOptionKey:(NSString *)key {
    self = [super init];
    if(self) {
        self.optionInfo = [NSUserDefaults getInfoForOptionKey:key];
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
    self.navigationItem.title = self.optionInfo.optionName;
}

#pragma mark -
#pragma mark WTGroupTableViewController methods to overwrite

- (void)configureDataSource {
    [self.dataSourceDictionary setObject:self.optionInfo.optionsArray forKey:kDefaultSettingOptionDataSourceKey];
    [self.dataSourceIndexArray addObject:kDefaultSettingOptionDataSourceKey];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = [self.optionInfo.optionsArray objectAtIndex:indexPath.row];
    
    NSNumber *chosen = [self.optionInfo.optionChosenStatusArray objectAtIndex:indexPath.row];
    if(chosen.boolValue)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *chosenNumber = [self.optionInfo.optionChosenStatusArray objectAtIndex:indexPath.row];
    if(chosenNumber.boolValue == YES && self.optionInfo.allowMultiOptions == NO)
        return;
    
    NSMutableArray *array = [NSMutableArray array];
    [self.optionInfo.optionChosenStatusArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if(!self.optionInfo.allowMultiOptions) {
            NSNumber *item = [NSNumber numberWithBool:idx == indexPath.row ? YES : NO];
            [array addObject:item];
        } else {
            NSNumber *oldStatus = obj;
            NSNumber *item = [NSNumber numberWithBool:idx == indexPath.row ? !chosenNumber.boolValue : oldStatus.boolValue];
            [array addObject:item];
        }
    }];
    self.optionInfo.optionChosenStatusArray = array;
    
    [NSUserDefaults setSettingOptionInfo:self.optionInfo];
    
    [self.tableView reloadData];
}


@end
