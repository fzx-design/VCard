//
//  ShelfViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-7-2.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "ShelfViewController.h"
#import "UIView+Resize.h"
#import "WBClient.h"
#import "ShelfDrawerView.h"
#import "UIApplication+Addition.h"
#import "Group.h"

#define kShelfHeight 149.0
#define kNumberOfDrawerPerPage 5

@implementation WBGroupInfo

@end

@interface ShelfViewController () {
    UIImageView *_shelfBGImageView;
    UIImageView *_shelfEdgeImageView;
    NSInteger _numberOfPages;
}

@end

@implementation ShelfViewController

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
    [self initScrollView];
    [self setUpSettingView];
    [self setUpGroupsInfo];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark - Group Infomation Behavior
- (void)setUpGroupsInfo
{
    [self getGroups];
    [self getTrends];
}

- (void)getGroups
{
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            NSArray *resultArray = [client.responseJSONObject objectForKey:@"lists"];
            for (NSDictionary *dict in resultArray) {
                [Group insertGroupInfo:dict inManagedObjectContext:self.managedObjectContext];
            }
        }
        
        [self.managedObjectContext processPendingChanges];
        [self.fetchedResultsController performFetch:nil];
        
        [self performSelector:@selector(setUpScrollView) withObject:nil afterDelay:0.001];
    }];
    
    [client getGroups];
}

- (void)getTrends
{
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            NSArray *resultArray = client.responseJSONObject;
            for (NSDictionary *dict in resultArray) {
                Group *group = [Group insertTopicInfo:dict inManagedObjectContext:self.managedObjectContext];
                [self getPicURLForTopic:group];
            }
        }
        
        [self.managedObjectContext processPendingChanges];
        [self.fetchedResultsController performFetch:nil];
        
        [self performSelector:@selector(setUpScrollView) withObject:nil afterDelay:0.001];
    }];
    
    [client getTrends];
}

- (void)getPicURLForTopic:(Group *)group
{
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            NSArray *resultArray = client.responseJSONObject;
            for (NSDictionary *dict in resultArray) {
                NSString *picURL = [dict objectForKey:@"thumbnail_pic"];
                if (picURL && ![picURL isEqualToString:@""]) {
                    group.picURL = picURL;
                    break;
                }
            }
     
         if(group.index.intValue > 0 && group.index.intValue < _drawerViewArray.count) {
             ShelfDrawerView *view = [_drawerViewArray objectAtIndex:group.index.intValue];
             [view loadImageFromURL:group.picURL completion:nil];
         }
     }
     }];
    [client searchTopic:group.name
         startingAtPage:0
                  count:10];
}

- (void)changeCastViewSource:(UITapGestureRecognizer *)sender
{
    ShelfDrawerView *view = (ShelfDrawerView *)sender.view;
    Group *group = [self.fetchedResultsController.fetchedObjects objectAtIndex:view.index];

    NSString *type = [NSString stringWithFormat:@"%d",group.type.intValue];
    NSString *name = group.groupID;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldChangeCastviewDataSource
                                                        object:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                name, kNotificationObjectKeyDataSourceDescription,
                                                                type, kNotificationObjectKeyDataSourceType, nil]];
}

- (void)configureRequest:(NSFetchRequest *)request
{
    NSSortDescriptor *sortDescriptor;
	
    sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    request.entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
}

#pragma mark - Rotation Behavior
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration 
{
    [self resetContentSize:toInterfaceOrientation];
    [self resetContentLayout:toInterfaceOrientation];
    [self resetSettingViewLayout:toInterfaceOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGFloat toWidth = UIInterfaceOrientationIsPortrait(fromInterfaceOrientation) ? 1024 : 768;
    [_scrollView resetWidth:toWidth];
    _scrollView.contentOffset = CGPointMake([UIApplication screenWidth] * _pageControl.currentPage, 0.0);
}

- (void)resetContentSize:(UIInterfaceOrientation)orientation
{
    CGFloat toWidth = UIInterfaceOrientationIsPortrait(orientation) ? 768 : 1024;
    CGFloat fromWidth = UIInterfaceOrientationIsPortrait(orientation) ? 1024 : 768;
    NSInteger page = _scrollView.contentOffset.x / fromWidth;
    _scrollView.contentSize = CGSizeMake(toWidth * _numberOfPages, kShelfHeight);
    _scrollView.contentOffset = CGPointMake(page * toWidth, 0.0);
    
    [self resetBGImageView:toWidth];
}

- (void)resetContentLayout:(UIInterfaceOrientation)orientation
{
    int index = 0;
    int drawWith = UIInterfaceOrientationIsPortrait(orientation) ? 155 : 200;
    int initialOffset = UIInterfaceOrientationIsPortrait(orientation) ? 28 : 65;
    int scrollViewWidth = UIInterfaceOrientationIsPortrait(orientation) ? 768.0 : 1024.0;
    for (UIView* view in _drawerViewArray) {
        NSInteger page = index / kNumberOfDrawerPerPage + 1;
        NSInteger pageOffset = index % kNumberOfDrawerPerPage;
        CGFloat originX = scrollViewWidth * page + drawWith * pageOffset + initialOffset;
        [view resetOriginX:originX];
        index++;
    }
}

- (void)resetSettingViewLayout:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        CGFloat center = 384.0;
        [_switchToPicButton resetOriginX:center - 2.0];
        [_switchToTextButton resetOriginX:center - _switchToTextButton.frame.size.width + 2.0];
        [_brightnessSlider resetOriginX:_switchToPicButton.frame.origin.x + _switchToPicButton.frame.size.width + 51.0];
        [_fontSizeSlider resetOriginX:_switchToTextButton.frame.origin.x - _fontSizeSlider.frame.size.width - 50.0];
    } else {
        CGFloat center = 512.0;
        [_switchToPicButton resetOriginX:center - 2.0];
        [_switchToTextButton resetOriginX:center - _switchToTextButton.frame.size.width + 2.0];
        [_brightnessSlider resetOriginX:_switchToPicButton.frame.origin.x + _switchToPicButton.frame.size.width + 143.0];
        [_fontSizeSlider resetOriginX:_switchToTextButton.frame.origin.x - _fontSizeSlider.frame.size.width - 143.0];
    }
    
}

#pragma mark - Setting View Behavior
- (void)setUpSettingView
{
    [_brightnessSlider setThumbImage:[UIImage imageNamed:@"motions_slider_thumb.png"] forState:UIControlStateNormal];
	[_brightnessSlider setThumbImage:[UIImage imageNamed:@"motions_slider_thumb.png"] forState:UIControlStateHighlighted];
	[_brightnessSlider setMinimumTrackImage:[UIImage imageNamed:@"transparent.png"] forState:UIControlStateNormal];
	[_brightnessSlider setMaximumTrackImage:[UIImage imageNamed:@"transparent.png"] forState:UIControlStateNormal];
    
    [_fontSizeSlider setThumbImage:[UIImage imageNamed:@"slider_font_thumb.png"] forState:UIControlStateNormal];
	[_fontSizeSlider setThumbImage:[UIImage imageNamed:@"slider_font_thumb.png"] forState:UIControlStateHighlighted];
	[_fontSizeSlider setMinimumTrackImage:[UIImage imageNamed:@"transparent.png"] forState:UIControlStateNormal];
	[_fontSizeSlider setMaximumTrackImage:[UIImage imageNamed:@"transparent.png"] forState:UIControlStateNormal];
    
    _brightnessSlider.maximumValue = 1.0;
    _brightnessSlider.minimumValue = 0.1;
    _brightnessSlider.value = [[UIScreen mainScreen] brightness];
    
    [ThemeResourceProvider configButtonBrown:_detailSettingButton];
    _switchToPicButton.selected = YES;
    _switchToTextButton.selected = NO;
}

#pragma mark - Scroll View Behavior
- (void)initScrollView
{
    NSInteger numberOfDrawers = 10;
    _numberOfPages = numberOfDrawers / kNumberOfDrawerPerPage + 1;
    [_pageControl setImageNormal:[UIImage imageNamed:@"shelf_pagecontrol_bg.png"]];
    [_pageControl setImageCurrent:[UIImage imageNamed:@"shelf_pagecontrol_hover.png"]];
    [_pageControl setImageSetting:[UIImage imageNamed:@"shelf_pagecontrol_settings_bg.png"]];
    [_pageControl setImageSettingHighlight:[UIImage imageNamed:@"shelf_pagecontrol_settings_hover.png"]];
    _pageControl.numberOfPages = _numberOfPages;
    _pageControl.currentPage = 1;
    
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width * _numberOfPages, _scrollView.frame.size.height)];
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delegate = self;
    _scrollView.contentOffset = CGPointMake(_scrollView.frame.size.width, 0.0);
    [_scrollView resetWidth:self.view.bounds.size.width];
    [_scrollView resetHeight:149.0];
    ShelfBackgroundView *view = (ShelfBackgroundView *)self.view;
    view.scrollViewReference = (ShelfScrollView *)_scrollView;
    
    _shelfEdgeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 62.0, 136.0)];
    _shelfEdgeImageView.image = [UIImage imageNamed:@"shelf_wood_edge.png"];
    _shelfEdgeImageView.contentMode = UIViewContentModeTop;
    _shelfEdgeImageView.autoresizingMask = UIViewAutoresizingNone;
    _shelfEdgeImageView.userInteractionEnabled = NO;
    [_shelfEdgeImageView resetOriginX:_scrollView.frame.size.width - _shelfEdgeImageView.frame.size.width];
    [_scrollView insertSubview:_shelfEdgeImageView belowSubview:_shelfBorderImageView];
    
    _shelfBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 6.0, 1024.0, 136.0)];
    _shelfBGImageView.image = [UIImage imageNamed:@"shelf_bg.png"];
    _shelfBGImageView.contentMode = UIViewContentModeLeft;
    _shelfBGImageView.autoresizingMask = UIViewAutoresizingNone;
    _shelfBGImageView.userInteractionEnabled = NO;
    [_shelfBGImageView resetOriginX:_scrollView.frame.size.width];
    [_scrollView insertSubview:_shelfBGImageView belowSubview:_shelfBorderImageView];
    
    [_shelfBorderImageView resetWidth:1024.0];
}

- (void)setUpScrollView
{
    if (_drawerViewArray) {
        for (UIView *view in _drawerViewArray) {
            [view removeFromSuperview];
        }
        [_drawerViewArray removeAllObjects];
        _drawerViewArray = nil;
    }
    
    _drawerViewArray = [[NSMutableArray alloc] init];
    NSInteger numberOfDrawers = self.fetchedResultsController.fetchedObjects.count;
    _numberOfPages = ceil((float)numberOfDrawers / (float)kNumberOfDrawerPerPage) + 1;
    _pageControl.numberOfPages = _numberOfPages;
    _pageControl.currentPage = 1;
    
    NSInteger index = 0;
    
    for (Group *group in self.fetchedResultsController.fetchedObjects) {
        ShelfDrawerView *drawerView = [[ShelfDrawerView alloc] initWithFrame:CGRectMake(0.0, 40.0, 95.0, 95.0)
                                                                   topicName:group.name
                                                                      picURL:group.picURL
                                                                       index:index
                                                                        type:group.type.intValue];
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeCastViewSource:)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        [drawerView addGestureRecognizer:tapGestureRecognizer];
        
        [_scrollView addSubview:drawerView];
        [_drawerViewArray addObject:drawerView];
        group.index = [NSNumber numberWithInt:index];
        index++;
    }
    
    [self resetContentLayout:[UIApplication screenWidth] == 1024.0 ? UIInterfaceOrientationLandscapeLeft : UIInterfaceOrientationPortrait];
}

- (void)loadImages
{
    for (ShelfDrawerView *view in _drawerViewArray) {
        if (!view.imageLoaded) {
            Group *group = [self.fetchedResultsController.fetchedObjects objectAtIndex:view.index];
            [view loadImageFromURL:group.picURL completion:nil];
        }
    }
}

- (void)resetBGImageView:(CGFloat)currentWidth
{
    [_shelfEdgeImageView resetOriginX:currentWidth - _shelfEdgeImageView.frame.size.width];
    if (_pageControl.currentPage > 0) {
        currentWidth = _pageControl.currentPage * currentWidth;
    }
    [_shelfBGImageView resetOriginX:currentWidth];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat screenWidth = [UIApplication screenWidth];
    if (scrollView.contentOffset.x >= screenWidth) {
        [_shelfBGImageView resetOriginX:_scrollView.contentOffset.x];
    } else {
        [_shelfBGImageView resetOriginX:screenWidth];
    }
    [_shelfBorderImageView resetOriginX:_scrollView.contentOffset.x];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger page = fabs(scrollView.contentOffset.x) / scrollView.frame.size.width;
    _pageControl.currentPage = page;
}

#pragma mark - IBActions
- (IBAction)didChangeValueOfSlider:(UISlider *)sender
{
    if ([sender isEqual:_brightnessSlider]) {
        [[UIScreen mainScreen] setBrightness:_brightnessSlider.value];
    }
}

- (IBAction)didEndDraggingSlider:(UISlider *)sender
{
    
}

- (IBAction)didClickDetialSettingButton:(UIButton *)sender
{
    
}

- (IBAction)didClickSwitchModeButton:(UIButton *)sender
{
    BOOL switchToPicButtonClicked = [sender isEqual:_switchToPicButton];
    _switchToPicButton.selected = switchToPicButtonClicked;
    _switchToTextButton.selected = !switchToPicButtonClicked;
}

- (IBAction)didChangePageControlValue:(UIPageControl *)sender
{
    NSInteger page = sender.currentPage;
    CGRect frame = _scrollView.frame;
    frame.origin.x = page * frame.size.width;
    [_scrollView scrollRectToVisible:frame animated:YES];
}


@end
