//
//  TopicViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-7-4.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "TopicViewController.h"
#import "WBClient.h"
#import "Group.h"

@interface TopicViewController () {
    BOOL _isTopicFollowed;
    NSString *_topicID;
    Group *_group;
}

@end

@implementation TopicViewController

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
    [self setUpViews];
    [self loadTopicStatus];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)initialLoad
{
    [self.statusTableViewController refresh];
}

- (void)refresh
{
    [self.statusTableViewController refresh];
}

- (void)enableScrollToTop
{
    self.statusTableViewController.tableView.scrollsToTop = YES;
}

- (void)disableScrollToTop
{
    self.statusTableViewController.tableView.scrollsToTop = NO;
}

- (void)clearPage
{
    [_statusTableViewController.view removeFromSuperview];
    _statusTableViewController = nil;
}

- (void)setUpViews
{
    [self.topShadowImageView resetOrigin:[self frameForTableView].origin];
    [self.backgroundView addSubview:self.topShadowImageView];
    
    [ThemeResourceProvider configButtonPaperLight:_followTopicButton];
    _topicTitleLabel.text = [NSString stringWithFormat:@"#%@#", _searchKey];
}

- (void)loadTopicStatus
{
    _group = [Group groupWithName:_searchKey inManagedObjectContext:self.managedObjectContext];
    _isTopicFollowed = _group != nil;
    NSString *buttonText = _isTopicFollowed ? @"取消关注" : @"关注话题";
    _followTopicButton.titleLabel.text = buttonText;
}

#pragma mark - IBActions
- (IBAction)didClickFollowTopicButton:(UIButton *)sender
{
    if (_isTopicFollowed) {
        [self unfollowTopic];
        _followTopicButton.titleLabel.text = @"取消关注中";
    } else {
        [self followTopic];
        _followTopicButton.titleLabel.text = @"关注中";
    }
    _followTopicButton.userInteractionEnabled = NO;
    
}

- (void)followTopic
{
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            NSDictionary *dict = client.responseJSONObject;
            NSString *groupID = [dict objectForKey:@"topicid"];
            _group = [Group insertTopicWithName:_searchKey andID:groupID inManangedObjectContext:self.managedObjectContext];
            [self.managedObjectContext processPendingChanges];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldCreateNewGroup object:_group];
            _followTopicButton.titleLabel.text = @"取消关注";
            _isTopicFollowed = YES;
        } else {
            _followTopicButton.titleLabel.text = @"关注话题";
        }
        _followTopicButton.userInteractionEnabled = YES;
    }];
    [client followTrend:_searchKey];
}

- (void)unfollowTopic
{
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldDeleteGroup object:_group];
            _followTopicButton.titleLabel.text = @"关注话题";
            _isTopicFollowed = NO;
            _group = nil;
        } else {
            _followTopicButton.titleLabel.text = @"取消关注";
        }
        _followTopicButton.userInteractionEnabled = YES;
    }];
    [client unfollowTrend:_group.groupID];
}


#pragma mark - Properties
- (CGRect)frameForTableView
{
    CGFloat originY = 50;
    CGFloat height = self.view.frame.size.height - originY;
    return CGRectMake(24.0, originY, 382.0, height);
}

- (ProfileStatusTableViewController *)statusTableViewController
{
    if (!_statusTableViewController) {
        _statusTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileStatusTableViewController"];
        _statusTableViewController.pageIndex = self.pageIndex;
        _statusTableViewController.view.frame = [self frameForTableView];
        _statusTableViewController.tableView.frame = [self frameForTableView];
        _statusTableViewController.user = self.currentUser;
        _statusTableViewController.type = StatusTableViewControllerTypeTopicStatus;
        _statusTableViewController.searchKey = _searchKey;
        [self.backgroundView insertSubview:_statusTableViewController.view belowSubview:self.topShadowImageView];
    }
    return _statusTableViewController;
}

@end
