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
#import "NSUserDefaults+Addition.h"
#import "SettingOptionViewController.h"

#define kSettingCurrentUserCell @"kSettingCurrentUserCell"

@interface SettingRootViewController ()

@property (nonatomic, strong) NSMutableArray *settingSectionInfoArray;
@property (nonatomic, strong) UIImage *currentUserAvatarImage;

@property (nonatomic, assign) CGFloat currentFontSize;
@property (nonatomic, assign) BOOL isPictureEnabled;

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
    
    _currentFontSize = [NSUserDefaults currentFontSize];
    _isPictureEnabled = [NSUserDefaults isPictureEnabled];
}

- (void)viewDidUnload
{
    self.tableView = nil;
    [super viewDidUnload];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];
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
    [NSUserDefaults updateCurrentFontSize];
    if ([NSUserDefaults currentFontSize] != _currentFontSize) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameDidChangeFontSize object:nil];
    } else if ([NSUserDefaults isPictureEnabled] != _isPictureEnabled) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldRefreshWaterflowView object:nil];
    }
    
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

- (void)didClickOptionCell:(NSString *)optionKey {
    SettingOptionViewController *vc = [[SettingOptionViewController alloc] initWithOptionKey:optionKey];
    [self.navigationController pushViewController:vc animated:YES];
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
    if([modalViewController isKindOfClass:[LoginViewController class]]) {
        UIViewController *vc = [UIApplication sharedApplication].topModalViewController;
        [self performSelector:@selector(dismissModalViewController:) withObject:vc afterDelay:1.0f];
    }
    
    if([modalViewController respondsToSelector:@selector(show)])
        [modalViewController performSelector:@selector(show)];
    else
        [UIApplication presentModalViewController:modalViewController animated:YES];
}

- (void)dismissModalViewController:(UIViewController *)modalViewController {
    [UIApplication dismissModalViewController:modalViewController animated:NO duration:MODAL_APPEAR_ANIMATION_DEFAULT_DURATION];
}

#pragma mark -
#pragma mark WTGroupTableViewController methods to overwrite

- (void)configureDataSource {
    NSArray *sectionArray = [[SettingInfoReader sharedReader] getSettingInfoSectionArray];
    for(SettingInfoSection *section in sectionArray) {
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
    
    if([info.wayToPresentViewController isEqualToString:kPushOptionViewController]) {
        SettingOptionInfo *optionInfo = [NSUserDefaults getInfoForOptionKey:info.nibFileName];
        __block NSMutableString *detailText = [NSMutableString string];
        __block BOOL allChosen = YES;
        __block BOOL noneChosen = YES;
        [optionInfo.optionsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSNumber *chosen = [optionInfo.optionChosenStatusArray objectAtIndex:idx];
            if(chosen.boolValue) {
                NSString *string = obj;
                if(detailText.length > 0)
                    string = [NSString stringWithFormat:@"、%@", string];
                [detailText appendString:string];
                
                noneChosen = NO;
            } else {
                allChosen = NO;
            }
        }];
        settingCell.detailTextLabel.text = detailText;
        
        if(allChosen)
            settingCell.detailTextLabel.text = @"全部";
        else if(noneChosen)
            settingCell.detailTextLabel.text = @"无";
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
    } else if([info.wayToPresentViewController isEqualToString:kPushOptionViewController]) {
        [self didClickOptionCell:info.nibFileName];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    SettingInfoSection *sectionInfo = [self.settingSectionInfoArray objectAtIndex:section];
    return sectionInfo.sectionHeader;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	SettingInfoSection *sectionInfo = [self.settingSectionInfoArray objectAtIndex:section];
    NSString *result = sectionInfo.sectionFooter;
    if([sectionInfo.sectionIdentifier isEqualToString:@"Group2"]) {
        if(![UIApplication isRetinaDisplayiPad])
            result = nil;
    }
    return result;
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
