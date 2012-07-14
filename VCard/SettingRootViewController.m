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
#import "UIImage+Addition.h"
#import "UIView+Resize.h"
#import "UIImage+Addition.h"
#import "LoginViewController.h"

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
        [UIImage loadSettingAvatarImageFromURL:self.currentUser.profileImageURL completion:^(UIImage *result) {
            _currentUserAvatarImage = result;
            [self.tableView reloadData];
        }];
    }
    return _currentUserAvatarImage;
}

#pragma mark - IBActions

- (void)didClickFinishButton {
    [UIApplication dismissModalViewControllerAnimated:YES];
}

- (void)didClickLogoutCell {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告"
                                       message:@"注销帐号将抹掉当前帐户信息"
                                      delegate:self
                             cancelButtonTitle:NSLocalizedString(@"取消", nil)
                             otherButtonTitles:NSLocalizedString(@"继续", nil), nil];
    [alert show];
}

- (void)didClickCreateNewAccountCell {
    LoginViewController *vc = [[LoginViewController alloc] initWithType:LoginViewControllerTypeCreateNewUser];
    [self presentModalViewController:vc];
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex != alertView.cancelButtonIndex) {
		LoginViewController *vc = [[LoginViewController alloc] initWithType:LoginViewControllerTypeDeleteCurrentUser];
        [self presentModalViewController:vc];
	}
}

#pragma mark - UI methods

- (void)presentModalViewController:(UIViewController *)modalViewController {
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
    
    
    if([modalViewController respondsToSelector:@selector(show)])
        [modalViewController performSelector:@selector(show)];
    else
        [UIApplication presentModalViewController:modalViewController animated:YES];
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
            if([info.itemTitle isEqualToString:@"高清图片"]) {
                if([UIApplication isRetinaDisplayiPad])
                    [itemTitleArray addObject:info];
            } else {
                [itemTitleArray addObject:info];
            }
        }
        [self.dataSourceDictionary setValue:itemTitleArray forKey:section.sectionIdentifier];
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SettingTableViewCell *settingCell = (SettingTableViewCell *)cell;
    settingCell.delegate = self;
    
    //SettingInfoSection *sectionInfo = ;
    NSArray *sectionInfoArray = [self.dataSourceDictionary objectForKey:[self.dataSourceIndexArray objectAtIndex:indexPath.section]];
    SettingInfo *info = [sectionInfoArray objectAtIndex:indexPath.row];
    
    settingCell.textLabel.text = info.itemTitle;
    settingCell.imageView.image = [UIImage imageNamed:info.imageFileName];
    settingCell.detailTextLabel.text = info.itemContent;
    
    if([info.accessoryType isEqualToString:kAccessoryTypeSwitch]) {
        [settingCell setSwitch];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        settingCell.itemSwitch.on = [defaults boolForKey:info.nibFileName];
        
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
    
    if([info.wayToPresentViewController isEqualToString:kModalViewController]) {
        UIViewController *vc = [[NSClassFromString(info.nibFileName) alloc] init];
        [self presentModalViewController:vc];
    } else if([info.wayToPresentViewController isEqualToString:kPushNavigationController]) {
        UIViewController *vc = [[NSClassFromString(info.nibFileName) alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if([info.wayToPresentViewController isEqualToString:kUseSelector]) {
        if([self respondsToSelector:NSSelectorFromString(info.nibFileName)])
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performSelector:NSSelectorFromString(info.nibFileName)];
#pragma clang diagnostic pop
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

#pragma mark - SettingTableViewCell delegate

- (void)settingTableViewCell:(SettingTableViewCell *)cell didChangeSwitch:(UISwitch *)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSArray *sectionInfoArray = [self.dataSourceDictionary objectForKey:[self.dataSourceIndexArray objectAtIndex:indexPath.section]];
    SettingInfo *info = [sectionInfoArray objectAtIndex:indexPath.row];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:sender.on forKey:info.nibFileName];
    [defaults synchronize];
}

@end
