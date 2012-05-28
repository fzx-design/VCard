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

@interface ProfileRelationTableViewController () {
    int _nextCursor;
    BOOL _loading;
}

@end

@implementation ProfileRelationTableViewController

@synthesize user = _user;
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
    [self refresh];
    _loading = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)clearData
{
    if (_type == RelationshipViewTypeFriends) {
        [self.user removeFriends:self.user.friends];
    }
    else {
        [self.user removeFollowers:self.user.followers];
    }
    //[self.tableView reloadData];
}

- (void)refresh
{
	_nextCursor = -1;
	[self performSelector:@selector(loadMoreData) withObject:nil afterDelay:0.01];
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
            NSArray *dictArray = [client.responseJSONObject objectForKey:@"users"];
			
			if (_nextCursor == -1) {
				[self clearData];
			}
			
            for (NSDictionary *dict in dictArray) {
                User *usr = [User insertUser:dict inManagedObjectContext:self.managedObjectContext];
                if (_type == RelationshipViewTypeFollowers) {
                    [self.user addFollowersObject:usr];
                }
                else {
                    [self.user addFriendsObject:usr];
                }
            }
            
            _nextCursor = [[client.responseJSONObject objectForKey:@"next_cursor"] intValue];
            
//            if (_nextCursor == 0) {
//                [self hideLoadMoreDataButton];
//            }
//            else {
//                [self showLoadMoreDataButton];
//            }
        }
        _loading = NO;
        
    }];
    
    if (_type == RelationshipViewTypeFriends) {
        [client getFriendsOfUser:self.user.userID cursor:_nextCursor count:20];
    }
    else {
        [client getFollowersOfUser:self.user.userID cursor:_nextCursor count:20];
    }
}

- (void)configureRequest:(NSFetchRequest *)request
{
    request.entity = [NSEntityDescription entityForName:@"User"
                                 inManagedObjectContext:self.managedObjectContext];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateDate" ascending:YES];
    if (_type == RelationshipViewTypeFriends) {
        request.predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", self.user.friends];
    }
    else {
        request.predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", self.user.followers];
    }
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
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
}

- (NSString *)customCellClassName
{
    return @"ProfileRelationTableViewCell";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//	[tableView deselectRowAtIndexPath:indexPath animated:YES];
//    User *usr = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    UserCardViewController *vc = [[UserCardViewController alloc] initWithUsr:usr];
//    vc.currentUser = self.currentUser;
//    vc.modalPresentationStyle = UIModalPresentationCurrentContext;
//    vc.modalTransitionStyle = self.modalTransitionStyle;
//	[self.navigationController pushViewController:vc animated:YES];
//    [vc release];
}


@end
