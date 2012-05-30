//
//  RefreshableCoreDataTableViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-5-29.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "RefreshableCoreDataTableViewController.h"
#import "UIView+Resize.h"

@interface RefreshableCoreDataTableViewController ()

@end

@implementation RefreshableCoreDataTableViewController

@synthesize backgroundViewA = _backgroundViewA;
@synthesize backgroundViewB = _backgroundViewB;

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
    [self.tableView resetWidth:384.0];
    [_tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
    _pullView = [[PullToRefreshView alloc] initWithScrollView:(UIScrollView *)self.tableView];
    [_pullView setDelegate:self];
    
    [self.tableView addSubview:_pullView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetLayoutAfterRotating) 
                                                 name:kNotificationNameOrientationWillChange
                                               object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)refresh
{
    //To override
}

- (void)resetTableViewLayout
{
    [self scrollViewDidScroll:self.tableView];
}

#pragma mark - UIScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentSize.height - scrollView.contentOffset.y < self.tableView.frame.size.height) {
        self.backgroundViewA.alpha = 1.0;
        self.backgroundViewB.alpha = 1.0;
        [self.tableView sendSubviewToBack:self.backgroundViewA];
        [self.tableView sendSubviewToBack:self.backgroundViewB];
    } else {
        self.backgroundViewA.alpha = 0.0;
        self.backgroundViewB.alpha = 0.0;
        
        return;
    }
    
    CGFloat top = scrollView.contentOffset.y;
    CGFloat bottom = top + scrollView.frame.size.height;
    
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
}

- (BOOL)view:(UIView *)view containsPoint:(CGFloat)originY
{
    return view.frame.origin.y <= originY && view.frame.origin.y + view.frame.size.height > originY;
}

- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change 
                       context:(void *)context 
{
    if ([keyPath isEqualToString:@"contentSize"]) {
        [self resetTableViewLayout];
    }
}

- (void)tableView:(UITableView *)tableView wilbDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self scrollViewDidScroll:self.tableView];
}

- (void)resetLayoutAfterRotating
{
    [self scrollViewDidScroll:self.tableView];
}


#pragma mark - Properties
- (BaseLayoutView*)backgroundViewA
{
    if (!_backgroundViewA) {
        _backgroundViewA = [[BaseLayoutView alloc] initWithFrame:CGRectMake(0.0, 0.0, 384.0, 800.0)];
        _backgroundViewA.autoresizingMask = UIViewAutoresizingNone;
        [self.tableView insertSubview:_backgroundViewA atIndex:1];
    }
    return _backgroundViewA;
}

- (BaseLayoutView*)backgroundViewB
{
    if (!_backgroundViewB) {
        _backgroundViewB = [[BaseLayoutView alloc] initWithFrame:CGRectMake(0.0, 0.0, 384.0, 800.0)];
        _backgroundViewB.autoresizingMask = UIViewAutoresizingNone;
        [_backgroundViewB resetOriginY:self.backgroundViewA.frame.origin.y + self.backgroundViewA.frame.size.height];
        [self.tableView insertSubview:_backgroundViewB atIndex:1];
    }
    return _backgroundViewB;
}

#pragma mark - PullToRefreshViewDelegate
- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view
{
    [self refresh];
}
@end
