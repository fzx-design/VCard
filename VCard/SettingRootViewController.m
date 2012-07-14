//
//  SettingRootViewController.m
//  VCard
//
//  Created by 王 紫川 on 12-7-12.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "SettingRootViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIApplication+Addition.h"
#import "SettingInfoReader.h"
#import "SettingTableViewCell.h"
#import "UIImage+Addition.h"
#import "UIView+Resize.h"
#import "UIImage+Addition.h"

#define kSettingCurrentUserCell @"kSettingCurrentUserCell"

@interface SettingRootViewController ()

@property (nonatomic, strong) NSMutableArray *settingSectionInfoArray;
@property (nonatomic, strong) UIImage *currentUserAvatarImage;

@end

@implementation SettingRootViewController

@synthesize settingSectionInfoArray = _settingSectionInfoArray;
@synthesize currentUserAvatarImage = _currentUserAvatarImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.settingSectionInfoArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStyleBordered target:self action:@selector(didClickFinishButton)];
    self.navigationItem.title = @"帐户和设置";
    self.navigationItem.leftBarButtonItem = barButton;
    
    self.navigationController.view.layer.masksToBounds = YES;
    self.navigationController.view.layer.cornerRadius = 5.0f;
    self.navigationController.view.autoresizingMask = UIViewAutoresizingNone;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Dispose of any resources that can be recreated.
    self.tableView = nil;
}

#pragma mark - Logic method

- (UIImage *)currentUserAvatarImage {
    if(!_currentUserAvatarImage) {
<<<<<<< HEAD
        UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        if (UIGraphicsBeginImageContextWithOptions != NULL) {
            [avatarImageView resetSize:CGSizeMake(29, 29)];
        }
        avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        [avatarImageView loadImageFromURL:self.currentUser.profileImageURL completion:^(BOOL succeeded){
            
            avatarImageView.layer.cornerRadius = 4.0f;
            avatarImageView.layer.masksToBounds = YES;
            
            avatarImageView.layer.borderColor = [UIColor colorWithRed:71 / 255. green:74 / 255. blue:78 / 255. alpha:1].CGColor;
            if (UIGraphicsBeginImageContextWithOptions != NULL) {
                avatarImageView.layer.borderWidth = 0.5;
            } else {
                avatarImageView.layer.borderWidth = 1;
            }
            
            
            CGSize targetSize = CGSizeMake(30, 30);
            if (UIGraphicsBeginImageContextWithOptions != NULL) {
                UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
            } else {
                UIGraphicsBeginImageContext(targetSize);
            }
            [avatarImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            _currentUserAvatarImage = croppedImage;
            
=======
        [UIImage loadSettingAvatarImageFromURL:self.currentUser.profileImageURL completion:^(UIImage *result) {
            _currentUserAvatarImage = result;
>>>>>>> setting加入header footer。
            [self.tableView reloadData];
        }];
    }
    return _currentUserAvatarImage;
}

#pragma mark - IBActions

- (void)didClickFinishButton {
    [UIApplication dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark WTGroupTableViewController methods to overwrite

- (NSString *)customCellClassName {
    return @"SettingTableViewCell";
}

- (void)configureDataSource {
    NSArray *sectionArray = [[SettingInfoReader sharedReader] getSettingInfoSectionArray];
    for(SettingInfoSection *section in sectionArray) {
        NSLog(@"section %@", section.sectionIdentifier);
        [self.dataSourceIndexArray addObject:section.sectionIdentifier];
        [self.settingSectionInfoArray addObject:section];
        NSMutableArray *itemTitleArray = [NSMutableArray array];
        for(SettingInfo *info in section.itemArray) {
            [itemTitleArray addObject:info];
        }
        [self.dataSourceDictionary setValue:itemTitleArray forKey:section.sectionIdentifier];
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
    }
    
    if([info.itemTitle isEqualToString:kSettingCurrentUserCell]) {
        settingCell.textLabel.text = self.currentUser.screenName;
        UIImage *avatarImage = self.currentUserAvatarImage;
        if(avatarImage)
            settingCell.imageView.image = avatarImage;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sectionInfoArray = [self.dataSourceDictionary objectForKey:[self.dataSourceIndexArray objectAtIndex:indexPath.section]];
    SettingInfo *info = [sectionInfoArray objectAtIndex:indexPath.row];
    
    if([info.wayToPresentViewController isEqualToString:kPushNavigationController]) {
        UIViewController *vc = [[NSClassFromString(info.nibFileName) alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    SettingInfoSection *sectionInfo = [self.settingSectionInfoArray objectAtIndex:section];
    return sectionInfo.sectionHeader;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	SettingInfoSection *sectionInfo = [self.settingSectionInfoArray objectAtIndex:section];
    return sectionInfo.sectionFooter;
}

@end
