//
//  SettingAppInfoViewController.m
//  VCard
//
//  Created by 王 紫川 on 12-7-12.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "SettingAppInfoViewController.h"
#import "SettingInfoReader.h"
#import "SettingTableViewCell.h"
#import "UIApplication+Addition.h"

@interface SettingAppInfoViewController ()

@end

@implementation SettingAppInfoViewController

@synthesize appInfoView = _appInfoView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.tableFooterView = self.appInfoView;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Dispose of any resources that can be recreated.
    self.appInfoView = nil;
}

- (NSString *)customCellClassName {
    return @"SettingTableViewCell";
}

#pragma mark -
#pragma mark WTGroupTableViewController methods to overwrite

- (void)configureDataSource {
    NSArray *sectionArray = [[SettingInfoReader sharedReader] getSettingAppInfoSectionArray];
    for(SettingInfoSection *section in sectionArray) {
        [self.dataSourceIndexArray addObject:section.sectionTitle];
        NSMutableArray *itemTitleArray = [NSMutableArray array];
        for(SettingInfo *info in section.itemArray) {
            [itemTitleArray addObject:info];
        }
        [self.dataSourceDictionary setValue:itemTitleArray forKey:section.sectionTitle];
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SettingTableViewCell *settingCell = (SettingTableViewCell *)cell;
    
    //SettingInfoSection *sectionInfo = ;
    NSArray *sectionInfoArray = [self.dataSourceDictionary objectForKey:[self.dataSourceIndexArray objectAtIndex:indexPath.section]];
    SettingInfo *info = [sectionInfoArray objectAtIndex:indexPath.row];
    
    settingCell.textLabel.text = info.itemTitle;
    settingCell.imageView.image = [UIImage imageNamed:info.imageFileName];
    settingCell.detailTextLabel.text = info.itemContent;
    
    if([info.accessoryType isEqualToString:kAccessoryTypeSwitch]) {
        [settingCell setSwitch];
    } else if([info.accessoryType isEqualToString:kAccessoryTypeDisclosure]) {
        [settingCell setDisclosureIndicator];
    } else if([info.accessoryType isEqualToString:kAccessoryTypeWatchButton]) {
        [settingCell setWatchButton];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sectionInfoArray = [self.dataSourceDictionary objectForKey:[self.dataSourceIndexArray objectAtIndex:indexPath.section]];
    SettingInfo *info = [sectionInfoArray objectAtIndex:indexPath.row];
    
    if([info.wayToPresentViewController isEqualToString:kModalViewController]) {
        [UIApplication dismissModalViewControllerAnimated:NO duration:0];
        
        UIView *tempBlackView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, [UIApplication screenWidth], [UIApplication screenHeight])];
        tempBlackView.backgroundColor = [UIColor blackColor];
        tempBlackView.alpha = 0.6f;
        tempBlackView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [[UIApplication sharedApplication].rootViewController.view addSubview:tempBlackView];
        
        UIView *superView = self.navigationController.view.superview;
        superView.frame = tempBlackView.frame;
        [[UIApplication sharedApplication].rootViewController.view addSubview:superView];
        superView.userInteractionEnabled = NO;
        
        [UIView animateWithDuration:0.5f animations:^{
            tempBlackView.alpha = 0;
        } completion:^(BOOL finished) {
            [tempBlackView removeFromSuperview];
            [superView removeFromSuperview];
        }];
        
        UIViewController *vc = [[NSClassFromString(info.nibFileName) alloc] init];
        if([vc respondsToSelector:@selector(show)])
            [vc performSelector:@selector(show)];
        else
            [UIApplication presentModalViewController:vc animated:YES];
    }
}

@end
