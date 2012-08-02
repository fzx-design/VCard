//
//  SearchViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-7-4.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "SearchViewController.h"
#import "UIView+Resize.h"

#define kSearchSegmentButtonHiddenOriginY   -44
#define kSearchSegmentButtonShownOriginY    0

@interface SearchViewController ()

@end

@implementation SearchViewController

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
    [self.backgroundView addSubview:self.searchTableViewController.view];
    [self.topShadowImageView resetOriginY:[self frameForTableView].origin.y];
    [self.topShadowImageView resetOriginX:0.0];
    [self.view addSubview:self.topShadowImageView];

    _searchUserButton.selected = NO;
    _searchStatusButton.selected = YES;
    [_searchUserButton resetOriginY:kSearchSegmentButtonHiddenOriginY];
    [_searchStatusButton resetOriginY:kSearchSegmentButtonShownOriginY];
    _segmentView.hidden = YES;
    [[_searchBar.subviews objectAtIndex:0] removeFromSuperview];
    _searchBar.delegate = self;
    _searchBarCoverView.image = [[UIImage imageNamed:kRLCastViewBGUnit] resizableImageWithCapInsets:UIEdgeInsetsZero];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_searchTableViewController viewWillDisappear:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initialLoad
{
    [self.searchTableViewController getHotTopics];
}

- (void)stackScrolling:(CGFloat)speed
{
    CGFloat angle = -0.089 * speed / 20;
    [self.searchTableViewController swingWithAngle:angle];
}

- (void)stackScrollingStartFromLeft:(BOOL)toLeft
{
    //TODO: Test
    CGFloat factor = toLeft ? 1.0 : -1.0;
    [self.searchTableViewController swingWithAngle:factor * 0.089 * M_PI];
}

- (void)stackDidScroll
{
    [self.searchBar resignFirstResponder];
}

- (void)clearPage
{
    [_searchTableViewController.view removeFromSuperview];
    _searchTableViewController = nil;
}

- (void)pagePopedFromStack
{
    [self.searchBar resignFirstResponder];
}

#pragma mark - Segment
- (void)showSegment
{
    if (_segmentView.hidden) {
        _segmentView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            [_searchStatusButton resetOriginY:kSearchSegmentButtonShownOriginY];
            [_searchUserButton resetOriginY:kSearchSegmentButtonShownOriginY];
            
            CGRect frame = _searchTableViewController.view.frame;
            [_searchTableViewController.view resetOriginY:frame.origin.y + 50];
            [_searchTableViewController.view resetHeight:frame.size.height - 50];
        }];
    }    
}

- (void)hideSegment
{
    if (!_segmentView.hidden) {
        [UIView animateWithDuration:0.3 animations:^{
            [_searchUserButton resetOriginY:kSearchSegmentButtonHiddenOriginY];
            [_searchStatusButton resetOriginY:kSearchSegmentButtonHiddenOriginY];
            
            CGRect frame = _searchTableViewController.view.frame;
            [_searchTableViewController.view resetOriginY:frame.origin.y - 50];
            [_searchTableViewController.view resetHeight:frame.size.height + 50];
        } completion:^(BOOL finished) {
            _segmentView.hidden = YES;
        }];
    }
}

#pragma mark - Textfield Delegate
- (void)keyboardWillHide:(id)sender
{
    NSString *searchKey = _searchBar.text;
    
    if (!searchKey || [searchKey isEqualToString:@""]) {
        [self hideSegment];
        [self.searchTableViewController setState:SearchTableViewStateNormal];
    } else {
        [_searchBar resignFirstResponder];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.searchTableViewController updateSuggestionWithKey:searchText];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.delegate stackViewPage:self shouldBecomeActivePageAnimated:YES];
    [self showSegment];
    [self.searchTableViewController setState:SearchTableviewStateTyping];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (![searchBar.text isEqualToString:@""]) {
        [self.searchTableViewController search];
    }
    [searchBar resignFirstResponder];
}

#pragma mark - IBActions
- (IBAction)didClickSegmentButton:(UIButton *)sender
{
    if ([sender isEqual:_searchStatusButton]) {
        if (!_searchStatusButton.selected) {
            [self.searchTableViewController setSearchingType:SearchingTargetTypeStatus];
            _searchStatusButton.selected = YES;
            _searchUserButton.selected = NO;
            _searchStatusButton.userInteractionEnabled = NO;
            _searchUserButton.userInteractionEnabled = YES;
        }
    } else {
        if (!_searchUserButton.selected) {
            [self.searchTableViewController setSearchingType:SearchingTargetTypeUser];
            _searchStatusButton.selected = NO;
            _searchUserButton.selected = YES;
            _searchUserButton.userInteractionEnabled = NO;
            _searchStatusButton.userInteractionEnabled = YES;
        }
    }
}

#pragma mark - SearchTableViewControllerDelegate
- (void)didSelectCell
{
    [_searchBar resignFirstResponder];
}

#pragma mark - Properties
- (CGRect)frameForTableView
{
    CGFloat originY = 44;
    CGFloat height = self.view.frame.size.height - originY;
    return CGRectMake(24.0, originY, 382.0, height);
}

- (SearchTableViewController *)searchTableViewController
{
    if (!_searchTableViewController) {
        _searchTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchTableViewController"];
        _searchTableViewController.pageIndex = self.pageIndex;
        _searchTableViewController.view.frame = [self frameForTableView];
        _searchTableViewController.tableView.frame = [self frameForTableView];
        _searchTableViewController.delegate = self;
        [self.backgroundView insertSubview:_searchTableViewController.view belowSubview:_searchBarCoverView];
    }
    return _searchTableViewController;
}

@end
