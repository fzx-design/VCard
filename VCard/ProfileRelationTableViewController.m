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


@interface ProfileRelationTableViewController () {
    int _nextCursor;
    int _page;
}

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
    _loading = NO;
    self.hasMoreViews = YES;
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
    if (_type == RelationshipViewTypeFriends) {
        [User deleteFriendsOfUser:self.user InManagedObjectContext:self.managedObjectContext withOperatingObject:self.coreDataIdentifier];
    } else if(_type == RelationshipViewTypeFollowers) {
        [User deleteFollowersOfUser:self.user InManagedObjectContext:self.managedObjectContext withOperatingObject:self.coreDataIdentifier];
    } else if(_type == RelationshipViewTypeSearch) {
        [User deleteUsersInManagedObjectContext:self.managedObjectContext withOperatingObject:self.coreDataIdentifier];
    }
}

- (void)loadMoreData
{
    if (_loading == YES) {
        return;
    }
    _loading = YES;
    
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            
            NSDictionary *result = client.responseJSONObject;
            if ([result isKindOfClass:[NSDictionary class]]) {
                NSArray *dictArray = [result objectForKey:@"users"];
                
                if (_nextCursor == -1) {
                    [self clearData];
                }
                
                for (NSDictionary *dict in dictArray) {
                    User *usr = [User insertUser:dict inManagedObjectContext:self.managedObjectContext withOperatingObject:self.coreDataIdentifier];
                    if (_type == RelationshipViewTypeFollowers) {
                        [self.user addFollowersObject:usr];
                    } else if(_type == RelationshipViewTypeFriends) {
                        [self.user addFriendsObject:usr];
                    } else if(_type == RelationshipViewTypeSearch) {
                        //TODO:
                    }
                }
                
                [self.managedObjectContext processPendingChanges];
                [self.fetchedResultsController performFetch:nil];
                
                _nextCursor = [[result objectForKey:@"next_cursor"] intValue];
                self.hasMoreViews = _nextCursor != 0;
                _page++;
            }
        }
        
        [self adjustBackgroundView];
        [self refreshEnded];
        [self finishedLoading];
        
    }];
        
    if (_type == RelationshipViewTypeFriends) {
        [client getFriendsOfUser:self.user.userID cursor:_nextCursor count:20];
    } else if (_type == RelationshipViewTypeFollowers){
        [client getFollowersOfUser:self.user.userID cursor:_nextCursor count:20];
    } else if (_type == RelationshipViewTypeSearch) {
        [client searchUser:_searchKey page:_page count:20];
    }
}

#pragma mark - Core Data Table View Method

- (void)configureRequest:(NSFetchRequest *)request
{
    request.entity = [NSEntityDescription entityForName:@"User"
                                 inManagedObjectContext:self.managedObjectContext];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateDate" ascending:YES];
    if (_type == RelationshipViewTypeFriends) {
        request.predicate = [NSPredicate predicateWithFormat:@"SELF IN %@ && operatedBy == %@ && currentUserID == %@", self.user.friends, self.coreDataIdentifier, self.currentUser.userID];
    } else if(_type == RelationshipViewTypeFollowers) {
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
