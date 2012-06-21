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
//    [self refresh];
    _loading = NO;
    _hasMoreViews = YES;
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
	[self performSelector:@selector(loadMoreData) withObject:nil afterDelay:0.01];
}

- (void)loadMore
{
    [self loadMoreData];
}

- (void)clearData
{
    if (_type == RelationshipViewTypeFriends) {
        [self.user removeFriends:self.user.friends];
    }
    else {
        [self.user removeFollowers:self.user.followers];
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
            
            [self.managedObjectContext processPendingChanges];
            [self.fetchedResultsController performFetch:nil];
            
            _nextCursor = [[client.responseJSONObject objectForKey:@"next_cursor"] intValue];
            _hasMoreViews = _nextCursor != 0;
        }
        
        [self adjustBackgroundView];
        [_loadMoreView finishedLoading:_hasMoreViews];
        [_pullView finishedLoading];
        _loading = NO;
        
    }];
    
    if (_type == RelationshipViewTypeFriends) {
        [client getFriendsOfUser:self.user.userID cursor:_nextCursor count:20];
    }
    else {
        [client getFollowersOfUser:self.user.userID cursor:_nextCursor count:20];
    }
}

#pragma mark - Core Data Table View Method

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
    User *usr = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:usr, kNotificationObjectKeyUser, [NSString stringWithFormat:@"%d", _stackPageIndex], kNotificationObjectKeyIndex, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameUserCellClicked object:dictionary];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell =  [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = YES;
}

#pragma mark - UIScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    if (_hasMoreViews && self.tableView.contentOffset.y >= self.tableView.contentSize.height - self.tableView.frame.size.height) {
        [self loadMoreData];
    }
}

#pragma mark - Properties

@end
