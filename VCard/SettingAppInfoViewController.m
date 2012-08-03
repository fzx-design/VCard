//
//  SettingAppInfoViewController.m
//  VCard
//
//  Created by 王 紫川 on 12-7-12.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "SettingAppInfoViewController.h"
#import "SettingInfoReader.h"
#import "UIApplication+Addition.h"
#import "UIImage+Addition.h"
#import "WBClient.h"

#define kTeamMemberCell         @"kTeamMemberCell"

#define POST_VIEW_SHOW_FROM_RECT    CGRectMake(([UIApplication screenWidth] - 44) / 2, ([UIApplication screenHeight] - 44) / 2, 44, 44)

@interface SettingAppInfoViewController ()

@property (nonatomic, strong) NSMutableDictionary *teamMemberAvatarCache;
@property (nonatomic, strong) NSMutableArray *settingSectionInfoArray;

@end

@implementation SettingAppInfoViewController

@synthesize teamMemberAvatarCache = _teamMemberAvatarCache;
@synthesize settingSectionInfoArray = _settingSectionInfoArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.teamMemberAvatarCache = [NSMutableDictionary dictionary];
        self.settingSectionInfoArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"关于";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Logic methods

- (UIImage *)avatarImageForUser:(User *)user {
    UIImage *result = [self.teamMemberAvatarCache objectForKey:user.userID];
    if(!result) {
        [UIImage loadSettingAvatarImageFromURL:user.profileImageURL completion:^(UIImage *result) {
            [self.teamMemberAvatarCache setObject:result forKey:user.userID];
            [self.tableView reloadData];
        }];
    }
    return result;
}

#pragma mark -
#pragma mark WTGroupTableViewController methods to overwrite

- (void)configureDataSource {
    NSArray *sectionArray = [[SettingInfoReader sharedReader] getSettingAppInfoSectionArray];
    for(SettingInfoSection *section in sectionArray) {
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
    settingCell.delegate = self;
    
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
    
    if([info.itemTitle isEqualToString:kTeamMemberCell]) {
        User *user = [User userWithID:info.nibFileName inManagedObjectContext:self.managedObjectContext withOperatingObject:kCoreDataIdentifierDefault operatableType:kOperatableTypeCurrentUser];
        if(user) {
            settingCell.textLabel.text = user.screenName;
            UIImage *avatarImage = [self avatarImageForUser:user];
            if(avatarImage)
                settingCell.imageView.image = avatarImage;
            
            if(user.following.boolValue) {
                settingCell.itemWatchButton.enabled = NO;
            } else {
                settingCell.itemWatchButton.enabled = YES;
            }
        } else {
            settingCell.textLabel.text = @"加载中";
            
            WBClient *client = [WBClient client];
            [client setCompletionBlock:^(WBClient *client) {
                NSDictionary *userDict = client.responseJSONObject;
                [User insertUser:userDict inManagedObjectContext:self.managedObjectContext withOperatingObject:kCoreDataIdentifierDefault operatableType:kOperatableTypeCurrentUser];
                [self.tableView reloadData];
            }];
            [client getUser:info.nibFileName];
            settingCell.itemWatchButton.enabled = NO;
        }
        
        if([user.userID isEqualToString:self.currentUser.userID]) {
            settingCell.itemWatchButton.enabled = NO;
            [settingCell.itemWatchButton setTitle:@"就是你" forState:UIControlStateDisabled];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sectionInfoArray = [self.dataSourceDictionary objectForKey:[self.dataSourceIndexArray objectAtIndex:indexPath.section]];
    SettingInfo *info = [sectionInfoArray objectAtIndex:indexPath.row];
    if([info.wayToPresentViewController isEqualToString:kUseSelector]) {
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

#pragma mark - IBActions

- (void)didClickTellFriendsCell {
    PostViewController *vc = [PostViewController getRecommendVCardNewStatusViewControllerWithDelegate:self];
    [vc showViewFromRect:POST_VIEW_SHOW_FROM_RECT];
}

- (void)didClickFeedbackCell {
    PostViewController *vc = [PostViewController getNewStatusViewControllerWithAtUserName:@"VCard微博" delegate:self];
    [vc showViewFromRect:POST_VIEW_SHOW_FROM_RECT];
}

- (void)didClickRateCell {
    NSString *urlString = kVCardAppStoreURL;
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

#pragma mark - SettingTableViewCell delegate

- (void)settingTableViewCell:(SettingTableViewCell *)cell didClickWatchButton:(UIButton *)button {
    button.enabled = NO;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSArray *sectionInfoArray = [self.dataSourceDictionary objectForKey:[self.dataSourceIndexArray objectAtIndex:indexPath.section]];
    SettingInfo *info = [sectionInfoArray objectAtIndex:indexPath.row];
    User *user = [User userWithID:info.nibFileName inManagedObjectContext:self.managedObjectContext withOperatingObject:kCoreDataIdentifierDefault operatableType:kOperatableTypeCurrentUser];
    
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        if(!client.hasError) {
            user.following = @(YES);
        } else {
            button.enabled = YES;
            
            NSNumber *weiboErrorCode = [client.responseError.userInfo objectForKey:@"error_code"];
            if(weiboErrorCode.intValue == 20506) {
                user.following = @(YES);
                button.enabled = NO;
            }
        }
    }];
    [client follow:user.userID];
    
}

#pragma mark - PostViewController Delegate

- (void)postViewController:(PostViewController *)vc willPostMessage:(NSString *)message {
    [vc dismissViewUpwards];
}

- (void)postViewController:(PostViewController *)vc didPostMessage:(NSString *)message {
    
}

- (void)postViewController:(PostViewController *)vc didFailPostMessage:(NSString *)message {
    
}

- (void)postViewController:(PostViewController *)vc willDropMessage:(NSString *)message {
    [vc dismissViewToRect:POST_VIEW_SHOW_FROM_RECT];
}

@end
