//
//  ProfileRelationTableViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-5-28.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "ProfileRelationTableViewController.h"
#import "ProfileRelationTableViewCell.h"
#import "UserAvatarImageView.h"
#import "WBClient.h"
#import "User.h"
#import "UIView+Resize.h"


@interface ProfileRelationTableViewController ()

@property (nonatomic, unsafe_unretained) int nextCursor;
@property (nonatomic, unsafe_unretained) int page;

@end

@implementation ProfileRelationTableViewController

@synthesize type = _type;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.autoresizingMask = UIViewAutoresizingNone;
    self.coreDataIdentifier = self.description;
    self.hasMoreViews = YES;
    self.isEmptyIndicatorForbidden = YES;
    _loading = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Data Operation

- (void)refresh
{
	_nextCursor = -1;
    _page = 1;
    [self.fetchedResultsController performFetch:nil];
	[self performSelector:@selector(loadMoreData) withObject:nil afterDelay:0.01];
}

- (void)loadMore
{
    [self loadMoreData];
}

- (void)clearData
{
    if (_type == RelationshipViewTypeSelfFriends || _type == RelationshipViewTypeUserFriends) {
        [User deleteFriendsOfUser:self.user InManagedObjectContext:self.managedObjectContext withOperatingObject:self.coreDataIdentifier];
    } else if(_type == RelationshipViewTypeSelfFollowers || _type == RelationshipViewTypeUserFollowers) {
        [User deleteFollowersOfUser:self.user InManagedObjectContext:self.managedObjectContext withOperatingObject:self.coreDataIdentifier];
    } else if(_type == RelationshipViewTypeSearch) {
        [User deleteUsersInManagedObjectContext:self.managedObjectContext withOperatingObject:self.coreDataIdentifier];
    }
    [self resetUnreadFollowerCount];
}

- (void)loadMoreData
{
    if (_loading == YES) {
        return;
    }
    _loading = YES;
    
    BlockARCWeakSelf weakSelf = self;
    
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            if (weakSelf == nil) {
                return;
            }
            
            NSDictionary *result = client.responseJSONObject;
            if ([result isKindOfClass:[NSDictionary class]]) {
                NSArray *dictArray = [result objectForKey:@"users"];
                
                if (weakSelf.nextCursor == -1) {
                    [weakSelf clearData];
                }
                
                for (NSDictionary *dict in dictArray) {
                    User *usr = [User insertUser:dict inManagedObjectContext:weakSelf.managedObjectContext withOperatingObject:weakSelf.coreDataIdentifier operatableType:kOperatableTypeNone];
                    if (weakSelf.type == RelationshipViewTypeSelfFollowers || weakSelf.type == RelationshipViewTypeUserFollowers) {
                        [weakSelf.user addFollowersObject:usr];
                    } else if(weakSelf.type == RelationshipViewTypeSelfFriends || weakSelf.type == RelationshipViewTypeUserFriends) {
                        [weakSelf.user addFriendsObject:usr];
                    } else if(weakSelf.type == RelationshipViewTypeSearch) {
                        //TODO:
                    }
                }
                
                [weakSelf.managedObjectContext processPendingChanges];
                [weakSelf.fetchedResultsController performFetch:nil];
                
                weakSelf.nextCursor = [[result objectForKey:@"next_cursor"] intValue];
                weakSelf.hasMoreViews = _nextCursor != 0;
                weakSelf.page++;
            }
        }
        
        [weakSelf adjustBackgroundView];
        [weakSelf refreshEnded];
        [weakSelf finishedLoading];
        
    }];
        
    if (_type == RelationshipViewTypeSelfFriends || _type == RelationshipViewTypeUserFriends) {
        [client getFriendsOfUser:self.user.userID cursor:_nextCursor count:20];
    } else if (_type == RelationshipViewTypeSelfFollowers || _type == RelationshipViewTypeUserFollowers){
        [client getFollowersOfUser:self.user.userID cursor:_nextCursor count:20];
    } else if (_type == RelationshipViewTypeSearch) {
        [client searchUser:_searchKey page:_page count:20];
    }
}

- (void)resetUnreadFollowerCount
{
    if (self.type != RelationshipViewTypeSelfFollowers) {
        return;
    }
    
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client){
        if (!client.hasError) {
            self.currentUser.unreadFollowingCount = @0;
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldUpdateUnreadFollowCount object:nil];
        }
    }];
    
    [client resetUnreadCount:kWBClientResetCountTypeFollower];
}

#pragma mark - Core Data Table View Method

- (void)configureRequest:(NSFetchRequest *)request
{
    request.entity = [NSEntityDescription entityForName:@"User"
                                 inManagedObjectContext:self.managedObjectContext];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateDate" ascending:YES];
    if (_type == RelationshipViewTypeSelfFriends || _type == RelationshipViewTypeUserFriends) {
        request.predicate = [NSPredicate predicateWithFormat:@"SELF IN %@ && operatedBy == %@ && currentUserID == %@", self.user.friends, self.coreDataIdentifier, self.currentUser.userID];
    } else if(_type == RelationshipViewTypeSelfFollowers || _type == RelationshipViewTypeUserFollowers) {
        request.predicate = [NSPredicate predicateWithFormat:@"SELF IN %@ && operatedBy == %@ && currentUserID == %@", self.user.followers, self.coreDataIdentifier, self.currentUser.userID];
    }  else if(_type == RelationshipViewTypeSearch) {
        request.predicate = [NSPredicate predicateWithFormat:@"operatedBy == %@ && currentUserID == %@",self.coreDataIdentifier, self.currentUser.userID];
    }
    request.sortDescriptors = @[sortDescriptor];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ProfileRelationTableViewCell *relationshipCell = (ProfileRelationTableViewCell *)cell;
    User *usr = [self.fetchedResultsController objectAtIndexPath:indexPath];
    relationshipCell.screenNameLabel.text = usr.screenName;
    
    NSString *infoString = [NSString stringWithFormat:@"%@ 位粉丝   %@ 条微博", usr.followersCount, usr.statusesCount];
    relationshipCell.infoLabel.text = infoString;
    
    [relationshipCell.avatarImageView loadImageFromURL:usr.profileImageURL
                                            completion:NULL];
    [relationshipCell.avatarImageView setVerifiedType:[usr verifiedTypeOfUser]];
    
    if (indexPath.row % 2 == 0) {
        relationshipCell.contentView.backgroundColor = [UIColor clearColor];
    } else {
        relationshipCell.contentView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.05];
    }
}

- (NSString *)customCellClassNameForIndex:(NSIndexPath *)indexPath
{
    return @"ProfileRelationTableViewCell";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *usr = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldShowUserByName object:@{kNotificationObjectKeyUserName: usr.screenName, kNotificationObjectKeyIndex: [NSString stringWithFormat:@"%i", self.pageIndex]}];
}

#pragma mark - UIScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    if (self.hasMoreViews && self.tableView.contentOffset.y >= self.tableView.contentSize.height - self.tableView.frame.size.height) {
        [self loadMoreData];
    }
}

@end
