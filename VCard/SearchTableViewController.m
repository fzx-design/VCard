//
//  SearchTableViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-7-4.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SearchTableViewController.h"
#import "BaseLayoutView.h"
#import "UIView+Resize.h"
#import "SearchTableviewSectionView.h"
#import "WBClient.h"
#import "SearchTableViewCell.h"
#import "SearchTableViewHighlightsCell.h"

@interface SearchTableViewController ()

@property (nonatomic, retain) BaseLayoutView *backgroundViewA;
@property (nonatomic, retain) BaseLayoutView *backgroundViewB;

@end

@implementation SearchTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _hotTopics = [[NSMutableArray alloc] init];
    _searchNameSuggestions = [[NSMutableArray alloc] initWithCapacity:5];
    _searchStatusSuggestions = [[NSMutableArray alloc] initWithCapacity:5];
    _searchKey = @"";
    _searchingType = SearchingTargetTypeStatus;
    
    _searchUserHistoryList = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] valueForKey:kUserDefaultKeySearchUserHistoryList]];
    _searchStatusHistoryList = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] valueForKey:kUserDefaultKeySearchStatusHistoryList]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self swingWithAngle:-0.089 * M_PI];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Data
- (void)getHotTopics
{
    WBClient *client = [WBClient client];
    
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            NSDictionary *results = [client.responseJSONObject objectForKey:@"trends"];
            NSMutableArray *trendDicts = [[NSMutableArray alloc] init];
            
            for (NSString *key in results) {
                trendDicts = [results objectForKey:key];
            }
            for (NSDictionary *dict in trendDicts) {
                NSString *topicName = [dict valueForKey:@"name"];
                [_hotTopics addObject:topicName];
            }
            
            [self reloadTableViewSection:1 withAnimation:UITableViewRowAnimationFade];
        }
    }];
    
    [client getHotTopics];
}

- (void)updateSuggestionWithKey:(NSString *)key
{
    _searchKey = key;
    if (_searchingType == SearchingTargetTypeStatus) {
        [self updateTopicSuggestionWithKey:key];
    } else {
        [self updateNameSuggestionWithKey:key];
    }
}

- (void)updateTopicSuggestionWithKey:(NSString *)key
{
    WBClient *client = [WBClient client];
    
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            if (![client.responseJSONObject isKindOfClass:[NSArray class]])
                return;
            [_searchStatusSuggestions removeAllObjects];
            NSArray *array = client.responseJSONObject;
            for(NSDictionary *dict in array) {
                NSString *topicName = [dict valueForKey:@"suggestion"];
                [_searchStatusSuggestions addObject:topicName];

            }
            [self reloadTableViewSection:0 withAnimation:UITableViewRowAnimationAutomatic];
        }
    }];
    
    [client getTopicSuggestions:key];
}

- (void)updateNameSuggestionWithKey:(NSString *)key
{
    WBClient *client = [WBClient client];
    
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            if (![client.responseJSONObject isKindOfClass:[NSArray class]])
                return;
            [_searchNameSuggestions removeAllObjects];
            NSArray *array = client.responseJSONObject;
            for (NSDictionary *dict in array) {
                NSString *screenName = [dict valueForKey:@"screen_name"];
                [_searchNameSuggestions addObject:screenName];
            }
            
            [self reloadTableViewSection:0 withAnimation:UITableViewRowAnimationAutomatic];
        }
    }];
    
    [client getUserSuggestions:key];
}

- (void)setState:(SearchTableViewState)state
{
    _tableViewState = state;
    [self.tableView reloadData];
    [self animateReload];
    [self performSelector:@selector(adjustBackgroundView) withObject:nil afterDelay:0.001];
}

- (void)setSearchingType:(SearchingTargetType)state
{
    _searchingType = state;
    [self.tableView reloadData];
    [self animateReload];
    [self performSelector:@selector(adjustBackgroundView) withObject:nil afterDelay:0.001];
    [self updateSuggestionWithKey:_searchKey];
}

- (void)reloadTableViewSection:(int)section withAnimation:(UITableViewRowAnimation)animation
{
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:animation];
    [self.tableView endUpdates];
    [self adjustBackgroundView];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _tableViewState == SearchTableviewStateTyping ? 1 : 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    SearchTableviewSectionView *view = [[SearchTableviewSectionView alloc] initWithFrame:CGRectMake(0.0, 0.0, 384.0, 23.0)];
    
    if (_tableViewState == SearchTableviewStateTyping) {
        if ([self isSearchKeyEmpty]) {
            [view setTitle:@"搜索历史"];
        } else {
            if (_searchingType == SearchingTargetTypeStatus) {
                [view setTitle:@"相关微博"];
            } else {
                [view setTitle:@"相关用户"];
            }
        }
    } else {
        switch (section) {
            case 0:
                [view setTitle:@"VCard 精选话题"];
                break;
            case 1:
                [view setTitle:@"24小时热门话题"];
                break;
                
            default:
                break;
        }
    }    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 23.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_tableViewState == SearchTableviewStateTyping) {
        return 50.0;
    }
    return indexPath.section == 0 ? 360.0 : 50.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = 0;
    
    if (_tableViewState == SearchTableviewStateTyping) {
        if (_searchingType == SearchingTargetTypeStatus) {
            if ([self isSearchKeyEmpty]) {
                count = _searchStatusHistoryList.count + 1;
            } else {
                count = _searchStatusSuggestions.count + 1;
            }
        } else {
            if ([self isSearchKeyEmpty]) {
                count = _searchUserHistoryList.count + 1;
            } else {
                count = _searchNameSuggestions.count + 1;
            }
        }
    } else {
        if (section == 0) {
            count = 1;
        } else if (section == 1) {
            count = _hotTopics.count;
        }
    }
    
    return count == 0 ? 1 : count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = nil;
    
    if (_tableViewState == SearchTableviewStateTyping) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SearchTableViewCell"];
        SearchTableViewCell *searchCell = (SearchTableViewCell *)cell;
        [self configureSearchingCell:searchCell atIndex:indexPath.row];
    } else {
        if (indexPath.section == 0) {
            //TODO:
            cell = [tableView dequeueReusableCellWithIdentifier:@"SearchTableViewHighlightsCell"];
        } else if (indexPath.section == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SearchTableViewCell"];
            SearchTableViewCell *searchCell = (SearchTableViewCell *)cell;
            if (_hotTopics.count > 0) {
                [searchCell setTitle:[_hotTopics objectAtIndex:indexPath.row]];
            } else {
                [searchCell setOperationTitle:@"暂无热门话题"];
            }
        }
    }
    
    if (indexPath.row % 2 == 0) {
        cell.contentView.backgroundColor = [UIColor clearColor];
    } else {
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.05];
    }
        
    return cell;
}

- (void)configureSearchingCell:(SearchTableViewCell *)cell atIndex:(int)index
{
    if ([self isSearchKeyEmpty]) {
        NSArray *array = _searchingType == SearchingTargetTypeStatus ? _searchStatusHistoryList : _searchUserHistoryList;
        [self configureCell:cell withHistoryList:array atIndex:index];
    } else {
        NSArray *array = _searchingType == SearchingTargetTypeStatus ? _searchStatusSuggestions : _searchNameSuggestions;
        [self configureCell:cell withSuggestionList:array atIndex:index];
    }
}

- (void)configureCell:(SearchTableViewCell *)cell
      withHistoryList:(NSArray *)array
              atIndex:(int)index
{
    if (array.count == 0) {
        [cell setOperationTitle:@"无历史"];
    } else {
        if (index == array.count) {
            [cell setOperationTitle:@"清除历史记录"];
        } else {
            [cell setTitle:[array objectAtIndex:index]];
        }
    }
}

- (void)configureCell:(SearchTableViewCell *)cell
   withSuggestionList:(NSArray *)array
              atIndex:(int)index
{
    if (index == 0) {
        NSString *type = _searchingType == SearchingTargetTypeStatus ? @"微博" : @"用户";
        [cell setTitle:[NSString stringWithFormat:@"搜索包含\"%@\"的%@", _searchKey, type]];
    } else {
        [cell setTitle:[array objectAtIndex:index - 1]];
    }
}

- (BOOL)isSearchKeyEmpty
{
    return !_searchKey || [_searchKey isEqualToString:@""];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL shouldResign = NO;
    if (_tableViewState == SearchTableViewStateNormal) {
        if (indexPath.section == 1 && _hotTopics.count > 0) {
            [self addTopicPageWithSearchKey:[_hotTopics objectAtIndex:indexPath.row]];
            shouldResign = YES;
        }
    } else {
        shouldResign = [self handleCellClickedEventAtIndex:indexPath.row];
    }
    
    if (shouldResign) {
        [_delegate didSelectCell];
    } else {
        [self restoreHistory];
    }
}

- (BOOL)handleCellClickedEventAtIndex:(int)index
{
    BOOL shouldResign = YES;
    if (_searchingType == SearchingTargetTypeStatus) {
        if ([self isSearchKeyEmpty]) {
            if (index < _searchStatusHistoryList.count) {
                [self addTopicPageWithSearchKey:[_searchStatusHistoryList objectAtIndex:index]];
            } else {
                [_searchStatusHistoryList removeAllObjects];
                shouldResign = NO;
            }
        } else {
            if (index == 0) {
                [self addTopicPageWithSearchKey:_searchKey];
                if ([_searchStatusHistoryList containsObject:_searchKey]) {
                    [_searchStatusHistoryList addObject:_searchKey];
                }
                
            } else {
                [self addTopicPageWithSearchKey:[_searchStatusSuggestions objectAtIndex:index - 1]];
            }
        }
    } else {
        if ([self isSearchKeyEmpty]) {
            if (index < _searchUserHistoryList.count) {
                [self showUserProfilePageWithKey:[_searchUserHistoryList objectAtIndex:index]];
            } else {
                [_searchUserHistoryList removeAllObjects];
                shouldResign = NO;
            }
        } else {
            if (index == 0) {
                [self addUserSearchPageWithSearchKey:_searchKey];
                if (![_searchUserHistoryList containsObject:_searchKey]) {
                    [_searchUserHistoryList addObject:_searchKey];
                }
            } else {
                [self showUserProfilePageWithKey:[_searchNameSuggestions objectAtIndex:index - 1]];
            }
        }
    }
    return shouldResign;
}

- (void)search
{
    if (_searchingType == SearchingTargetTypeStatus) {
        [self addTopicPageWithSearchKey:_searchKey];
        if ([_searchStatusHistoryList containsObject:_searchKey]) {
            [_searchStatusHistoryList addObject:_searchKey];
        }
    } else {
        [self addUserSearchPageWithSearchKey:_searchKey];
        if (![_searchUserHistoryList containsObject:_searchKey]) {
            [_searchUserHistoryList addObject:_searchKey];
        }
    }
    [self restoreHistory];
}

- (void)addTopicPageWithSearchKey:(NSString *)searchKey
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldShowTopic object:[NSDictionary dictionaryWithObjectsAndKeys:searchKey, kNotificationObjectKeySearchKey, [NSString stringWithFormat:@"%i", self.pageIndex], kNotificationObjectKeyIndex, nil]];
}

- (void)addUserSearchPageWithSearchKey:(NSString *)searchKey
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldShowUserSearchList object:[NSDictionary dictionaryWithObjectsAndKeys:searchKey, kNotificationObjectKeySearchKey, [NSString stringWithFormat:@"%i", self.pageIndex], kNotificationObjectKeyIndex, nil]];
}

- (void)showUserProfilePageWithKey:(NSString *)searchKey
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldShowUserByName object:[NSDictionary dictionaryWithObjectsAndKeys:searchKey, kNotificationObjectKeyUserName, [NSString stringWithFormat:@"%i", self.pageIndex], kNotificationObjectKeyIndex, nil]];
}

- (void)restoreHistory
{
    [[NSUserDefaults standardUserDefaults] setObject:_searchStatusHistoryList forKey:kUserDefaultKeySearchStatusHistoryList];
    [[NSUserDefaults standardUserDefaults] setObject:_searchUserHistoryList forKey:kUserDefaultKeySearchUserHistoryList];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self reloadTableViewSection:0 withAnimation:UITableViewRowAnimationTop];
}

- (void)animateReload
{
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionFade];
    [animation setSubtype:kCATransitionFromBottom];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setFillMode:kCAFillModeBoth];
    [animation setDuration:.3];
    [[self.tableView layer] addAnimation:animation forKey:@"UITableViewReloadDataAnimationKey"];
}

- (void)swingWithAngle:(CGFloat)angle
{
    if (_tableViewState == SearchTableViewStateNormal) {
        for (UITableViewCell *cell in self.tableView.visibleCells) {
            if ([cell isKindOfClass:[SearchTableViewHighlightsCell class]]) {
                [(SearchTableViewHighlightsCell *)cell swingWithAngle:angle];
            }
        }
    }
}

#pragma mark - Properties
#pragma mark - Adjust Background View
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self adjustBackgroundView];
}

- (void)adjustBackgroundView
{
    CGFloat top = self.tableView.contentOffset.y;
    CGFloat bottom = top + self.tableView.frame.size.height;
    
    UIView *upperView = nil;
    UIView *lowerView = nil;
    BOOL alignToTop = NO;
    
    if ((alignToTop = [self view:self.backgroundViewA containsPoint:top]) || [self view:self.backgroundViewB containsPoint:bottom]) {
        upperView = self.backgroundViewA;
        lowerView = self.backgroundViewB;
    } else if((alignToTop = [self view:self.backgroundViewB containsPoint:top]) || [self view:self.backgroundViewA containsPoint:bottom]) {
        upperView = self.backgroundViewB;
        lowerView = self.backgroundViewA;
    }
    
    if (upperView && lowerView) {
        if (alignToTop) {
            [lowerView resetOriginY:upperView.frame.origin.y + upperView.frame.size.height];
        } else {
            [upperView resetOriginY:lowerView.frame.origin.y - lowerView.frame.size.height];
        }
    } else {
        [self.backgroundViewA resetOriginY:top];
        [self.backgroundViewB resetOriginY:self.backgroundViewA.frame.origin.y + self.backgroundViewA.frame.size.height];
    }
    
    [self.tableView sendSubviewToBack:self.backgroundViewA];
    [self.tableView sendSubviewToBack:self.backgroundViewB];
}

- (BOOL)view:(UIView *)view containsPoint:(CGFloat)originY
{
    return view.frame.origin.y <= originY && view.frame.origin.y + view.frame.size.height > originY;
}

- (BaseLayoutView*)backgroundViewA
{
    if (!_backgroundViewA) {
        _backgroundViewA = [[BaseLayoutView alloc] initWithFrame:CGRectMake(0.0, 0.0, 384.0, 1024.0)];
        _backgroundViewA.autoresizingMask = UIViewAutoresizingNone;
        [self.tableView insertSubview:_backgroundViewA atIndex:0];
    }
    return _backgroundViewA;
}

- (BaseLayoutView*)backgroundViewB
{
    if (!_backgroundViewB) {
        _backgroundViewB = [[BaseLayoutView alloc] initWithFrame:CGRectMake(0.0, 0.0, 384.0, 1024.0)];
        _backgroundViewB.autoresizingMask = UIViewAutoresizingNone;
        [_backgroundViewB resetOriginY:self.backgroundViewA.frame.origin.y + self.backgroundViewA.frame.size.height];
        [self.tableView insertSubview:_backgroundViewB atIndex:0];
    }
    return _backgroundViewB;
}

@end
