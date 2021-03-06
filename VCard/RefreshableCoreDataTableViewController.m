//
//  RefreshableCoreDataTableViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-5-29.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "RefreshableCoreDataTableViewController.h"
#import "UIView+Resize.h"
#import "UIView+Addition.h"
#import "UIApplication+Addition.h"

@interface RefreshableCoreDataTableViewController ()

@property (nonatomic, retain) BaseLayoutView *backgroundViewA;
@property (nonatomic, retain) BaseLayoutView *backgroundViewB;

@end

@implementation RefreshableCoreDataTableViewController

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
    
    self.view.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    _refreshing = NO;
        
    [self.tableView resetWidth:384.0];
    _pullView = [[PullToRefreshView alloc] initWithScrollView:self.tableView];
    _pullView.delegate = self;
    _pullView.shouldAutoRotate = NO;
    
    _loadMoreView = [[LoadMoreView alloc] initWithScrollView:self.tableView];
    _loadMoreView.delegate = self;
    _loadMoreView.shouldAutoRotate = NO;;
    
    [self.tableView addSubview:_pullView];
    [self.tableView addSubview:_loadMoreView];
    
    [self adjustBackgroundView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [_pullView addObserver];
    _isBeingDisplayed = YES;
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self 
               selector:@selector(resetLayoutAfterRotating:) 
                   name:kNotificationNameOrientationChanged
                 object:nil];
    [center addObserver:self 
               selector:@selector(resetLayoutBeforeRotating:) 
                   name:kNotificationNameOrientationWillChange
                 object:nil];
    [center addObserver:self
               selector:@selector(adjustFont)
                   name:kNotificationNameDidChangeFontSize
                 object:nil];
    [center addObserver:self
               selector:@selector(adjustPictureMode)
                   name:kNotificationNameShouldRefreshWaterflowView
                 object:nil];
    [center addObserver:self
               selector:@selector(refreshAfterDeletingComment:)
                   name:kNotificationNameShouldDeleteComment
                 object:nil];
    [center addObserver:self
               selector:@selector(refreshAfterPostingComment)
                   name:kNotificationNameShouldRefreshAfterPost
                 object:nil];
    [center addObserver:self
               selector:@selector(refreshAfterDeletingStatuses:)
                   name:kNotificationNameShouldDeleteStatus
                 object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    _isBeingDisplayed = NO;
    [_pullView removeObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refresh
{
    //To override
}

- (void)loadMore
{
    //To override
}

- (void)refreshAfterPostingComment
{
    //To override
}

- (void)refreshAfterDeletingComment:(NSNotification *)notification
{
    //To override
}

- (void)refreshAfterDeletingStatuses:(NSNotification *)notification
{
    //To override
}

- (void)adjustFont
{
    [self.tableView reloadData];
    [self performSelector:@selector(adjustBackgroundView) withObject:nil afterDelay:0.1];
}

- (void)adjustPictureMode
{
    //To override
}

- (void)refreshEnded
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameRefreshEnded object:nil];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (_firstLoad) {
        return;
    }
    
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (_firstLoad) {
        return;
    }
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationTop];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (_firstLoad) {
        _firstLoad = NO;
        [self.tableView reloadData];
        [self performSelector:@selector(adjustBackgroundView) withObject:nil afterDelay:0.05];
    } else {
        [self.tableView endUpdates];
    }
}

#pragma mark - PullToRefreshViewDelegate
- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view
{
    [self refresh];
}

#pragma mark - LoadMoreViewDelegate
- (void)loadMoreViewShouldLoadMoreView:(LoadMoreView *)view
{
    [self loadMore];
}

#pragma mark - Notification
- (void)resetLayoutBeforeRotating:(NSNotification *)notification
{
    if ([(NSString *)notification.object isEqualToString:kOrientationPortrait]) {
        CGFloat height = 961.0 - self.view.frame.origin.y;
        [self.tableView resetHeight:height];
    }
    [self scrollViewDidScroll:self.tableView];
}

- (void)resetLayoutAfterRotating:(NSNotification *)notification
{
    if ([UIApplication isCurrentOrientationLandscape]) {
        CGFloat height = 705.0 - self.view.frame.origin.y;
        [self.tableView resetHeight:height];
    } else {
        CGFloat height = 961.0 - self.view.frame.origin.y;
        [self.tableView resetHeight:height];
    }
    [self scrollViewDidScroll:self.tableView];
}

#pragma mark - Adjust Background View
- (void)viewWillLayoutSubviews
{
    if ([UIApplication isCurrentOrientationLandscape]) {
        CGFloat height = 705.0 - self.view.frame.origin.y;
        [self.tableView resetHeight:height];
    } else {
        CGFloat height = 961.0 - self.view.frame.origin.y;
        [self.tableView resetHeight:height];
    }
    [self adjustBackgroundView];
}

- (void)viewDidLayoutSubviews
{
    [self adjustBackgroundView];
}

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
    
    [_loadMoreView resetPosition];
}

- (BOOL)view:(UIView *)view containsPoint:(CGFloat)originY
{
    return view.frame.origin.y <= originY && view.frame.origin.y + view.frame.size.height > originY;
}

- (void)finishedLoading
{
    _refreshing = NO;
    _loading = NO;
    [_pullView finishedLoading];
    [_loadMoreView finishedLoading:self.hasMoreViews];
    
    if (!self.isEmptyIndicatorForbidden) {
        [self checkContentEmpty];
    }
}

- (void)checkContentEmpty
{
    if (self.fetchedResultsController.fetchedObjects.count == 0) {
        self.emptyIndicatorViewController.view.hidden = NO;
        [self.emptyIndicatorViewController.view fadeIn];
    } else {
        if (_emptyIndicatorViewController) {
            [self.emptyIndicatorViewController.view fadeOutWithCompletion:^{
                self.emptyIndicatorViewController.view.hidden = YES;
            }];
        }
    }
}

- (void)showEmptyIndicator
{
    [self.emptyIndicatorViewController.view fadeIn];
}

- (void)hideEmptyIndicator
{
    [self.emptyIndicatorViewController.view fadeOut];
}

#pragma mark - UIScrollView Delegate
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    NSNumber *shouldSystemSupportScrollsTopTop = [[NSUserDefaults standardUserDefaults] valueForKey:kUserDefaultKeyShouldScrollToTop];
    return self.tableView.scrollsToTop && shouldSystemSupportScrollsTopTop.boolValue;
}

#pragma mark - Properties
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

- (EmptyIndicatorViewController *)emptyIndicatorViewController
{
    if (!_emptyIndicatorViewController) {
        _emptyIndicatorViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EmptyIndicatorViewController"];
        _emptyIndicatorViewController.delegate = self;
        [_emptyIndicatorViewController.view resetOriginY:20];
        [_emptyIndicatorViewController.view resetOriginX:0];
        [self.tableView addSubview:_emptyIndicatorViewController.view];
        _emptyIndicatorViewController.view.hidden = YES;
    }
    return _emptyIndicatorViewController;
}

#pragma mark - CommentTableViewCellDelegate
- (void)commentTableViewCellDidComment
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldRefreshAfterPost object:nil];
}

#pragma mark - Empty Indicator View Controller Delegate
- (void)didClickRefreshButton
{
    [self refresh];
}

@end
