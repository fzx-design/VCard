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
#import "UIImage+Addition.h"
#import "WBClient.h"

#define kVCardAppStoreURL       @"http://itunes.apple.com/cn/app/id420598288?mt=8"
#define kTeamMemberCell         @"kTeamMemberCell"

@interface SettingAppInfoViewController ()

@property (nonatomic, strong) NSMutableDictionary *teamMemberAvatarCache;
@property (nonatomic, strong) NSMutableArray *settingSectionInfoArray;

@end

@implementation SettingAppInfoViewController

@synthesize appInfoView = _appInfoView;

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
    self.tableView.tableFooterView = self.appInfoView;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Dispose of any resources that can be recreated.
    self.appInfoView = nil;
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

- (NSString *)customCellClassName {
    return @"SettingTableViewCell";
}

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
        User *user = [User userWithID:info.nibFileName inManagedObjectContext:self.managedObjectContext withOperatingObject:kCoreDataIdentifierDefault];
        if(user) {
            settingCell.textLabel.text = user.screenName;
            UIImage *avatarImage = [self avatarImageForUser:user];
            if(avatarImage)
                settingCell.imageView.image = avatarImage;
                
        } else {
            settingCell.textLabel.text = @"加载中";
            
            WBClient *client = [WBClient client];
            [client setCompletionBlock:^(WBClient *client) {
                NSDictionary *userDict = client.responseJSONObject;
                [User insertUser:userDict inManagedObjectContext:self.managedObjectContext withOperatingObject:kCoreDataIdentifierDefault];
                [self.tableView reloadData];
            }];
            [client getUser:info.nibFileName];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sectionInfoArray = [self.dataSourceDictionary objectForKey:[self.dataSourceIndexArray objectAtIndex:indexPath.section]];
    SettingInfo *info = [sectionInfoArray objectAtIndex:indexPath.row];
    if([info.wayToPresentViewController isEqualToString:kUseSelector]) {
        if([self respondsToSelector:NSSelectorFromString(info.nibFileName)])
            [self performSelector:NSSelectorFromString(info.nibFileName)];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    SettingInfoSection *sectionInfo = [self.settingSectionInfoArray objectAtIndex:section];
    return sectionInfo.sectionHeader;
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	SettingInfoSection *sectionInfo = [self.settingSectionInfoArray objectAtIndex:section];
    return sectionInfo.sectionFooter;
}

#pragma mark - IBActions

- (void)didClickTellFriendsCell {
    
}

- (void)didClickFeedbackCell {
    return;
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    if (picker) {
        picker.mailComposeDelegate = self;
        picker.modalPresentationStyle = UIModalPresentationPageSheet;
        
        NSString *subject = [NSString stringWithFormat:@"VCard HD 新浪微博用户反馈"];
        
        NSString *receiver = [NSString stringWithFormat:@"vcardhd@gmail.com"];
        [picker setToRecipients:[NSArray arrayWithObject:receiver]];
        
        [picker setSubject:subject];
        NSString *emailBody = [NSString stringWithFormat:@"反馈类型（功能建议 / 程序漏洞）：\n\n描述："];
        [picker setMessageBody:emailBody isHTML:NO];
        
        [[[UIApplication sharedApplication] rootViewController] presentModalViewController:picker animated:YES];
    }
}

- (void)didClickRateCell {
    NSString *urlString = kVCardAppStoreURL;
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

@end
