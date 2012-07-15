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

#define kShelfHeight 150.0
#define kNumberOfDrawerPerPage 5

@implementation WBGroupInfo

@end

@interface ShelfViewController () {
    UIImageView *_shelfBGImageView;
    NSInteger _numberOfPages;
    NSInteger _numberOfDrawerPerPage;
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
    [self setUpNotifications];
    
    UIInterfaceOrientation toInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [self updatePageControlAndScrollViewSize:toInterfaceOrientation];
    [self resetContentSize:toInterfaceOrientation];
    [self resetContentLayout:toInterfaceOrientation];
    [self resetSettingViewLayout:toInterfaceOrientation];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark - Notifications
- (void)setUpNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(createNewGroup:)
                   name:kNotificationNameShouldCreateNewGroup
                 object:nil];
    [center addObserver:self
               selector:@selector(deleteGroup:)
                   name:kNotificationNameShouldDeleteGroup
                 object:nil];
}

- (void)createNewGroup:(NSNotification *)notification
{
    Group *group = notification.object;
    [self.fetchedResultsController performFetch:nil];
    NSInteger index = self.fetchedResultsController.fetchedObjects.count - 1;
    [self updatePageControlAndScrollViewSize:[UIApplication sharedApplication].statusBarOrientation];
    [self createDrawerViewWithGroup:group index:index];
    [self getPicURLForTopic:group];
}

- (void)deleteGroup:(NSNotification *)notification
{
    Group *group = notification.object;
    [self removeDrawerViewAtIndex:group.index.intValue];
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
    NSString *name = group.name;
    NSString *groupID = group.groupID;
    if (type.intValue == 2) {
        name = [NSString stringWithFormat:@"#%@#", name];
        groupID = group.name;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldChangeCastviewDataSource
                                                        object:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                name, kNotificationObjectKeyDataSourceDescription,
                                                                type, kNotificationObjectKeyDataSourceType,
                                                                groupID, kNotificationObjectKeyDataSourceID, nil]];
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
    [self updatePageControlAndScrollViewSize:toInterfaceOrientation];
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
    int drawWith = UIInterfaceOrientationIsPortrait(orientation) ? 183 : 200;
    int initialOffset = UIInterfaceOrientationIsPortrait(orientation) ? 65 : 65;
    int scrollViewWidth = UIInterfaceOrientationIsPortrait(orientation) ? 768.0 : 1024.0;
    for (UIView* view in _drawerViewArray) {
        NSInteger page = index / _numberOfDrawerPerPage + 1;
        NSInteger pageOffset = index % _numberOfDrawerPerPage;
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
    [_brightnessSlider setThumbImage:[UIImage imageNamed:@"shelf_slider_thumb.png"] forState:UIControlStateNormal];
	[_brightnessSlider setThumbImage:[UIImage imageNamed:@"shelf_slider_thumb.png"] forState:UIControlStateHighlighted];
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
    [self.fetchedResultsController performFetch:nil];
    
    [_pageControl setImageNormal:[UIImage imageNamed:@"shelf_pagecontrol_bg.png"]];
    [_pageControl setImageCurrent:[UIImage imageNamed:@"shelf_pagecontrol_hover.png"]];
    [_pageControl setImageSetting:[UIImage imageNamed:@"shelf_pagecontrol_settings_bg.png"]];
    [_pageControl setImageSettingHighlight:[UIImage imageNamed:@"shelf_pagecontrol_settings_hover.png"]];
    
    [self updatePageControlAndScrollViewSize:[UIApplication sharedApplication].statusBarOrientation];
    _pageControl.currentPage = 1;

    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delegate = self;
    _scrollView.contentOffset = CGPointMake(_scrollView.frame.size.width, 0.0);
    [_scrollView resetWidth:[UIApplication screenWidth]];
    [_scrollView resetHeight:kShelfHeight];
    ShelfBackgroundView *view = (ShelfBackgroundView *)self.view;
    view.scrollViewReference = (ShelfScrollView *)_scrollView; 
    
    _shelfBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-62.0, 0.0, 1064.0, 150.0)];
    _shelfBGImageView.image = [UIImage imageNamed:@"shelf_bg.png"];
    _shelfBGImageView.contentMode = UIViewContentModeLeft;
    _shelfBGImageView.autoresizingMask = UIViewAutoresizingNone;
    _shelfBGImageView.userInteractionEnabled = NO;
    [_shelfBGImageView resetOriginX:_scrollView.frame.size.width - 62.0];
    [_scrollView insertSubview:_shelfBGImageView belowSubview:_shelfBorderImageView];
    
    [_shelfBorderImageView resetWidth:1024.0];
    
    [self.fetchedResultsController performFetch:nil];
    [self setUpScrollView];
    
    _coverView.alpha = 1.0;
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
    
    [self updatePageControlAndScrollViewSize:[UIApplication sharedApplication].statusBarOrientation];
    _pageControl.currentPage = 1;
    
    NSInteger index = 0;
    for (Group *group in self.fetchedResultsController.fetchedObjects) {
        [self createDrawerViewWithGroup:group index:index];
        index++;
    }
    
    [self resetContentLayout:[UIApplication sharedApplication].statusBarOrientation];
}

- (void)createDrawerViewWithGroup:(Group *)group index:(int)index
{
    ShelfDrawerView *drawerView = [[ShelfDrawerView alloc] initWithFrame:CGRectMake(0.0, 40.0, 95.0, 95.0)
                                                               topicName:group.name
                                                                  picURL:group.picURL
                                                                   index:index
                                                                    type:group.type.intValue
                                                                   empty:group.count.intValue == 0];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeCastViewSource:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [drawerView addGestureRecognizer:tapGestureRecognizer];
    [_scrollView addSubview:drawerView];
    [_drawerViewArray addObject:drawerView];
    
    [drawerView appearWithDuration:0.3];
    [self resetDrawerViewLayout:drawerView withIndex:index];
    group.index = [NSNumber numberWithInt:index];
    index++;
}

- (void)updatePageControlAndScrollViewSize:(UIInterfaceOrientation)orientation
{
    _numberOfDrawerPerPage = UIInterfaceOrientationIsPortrait(orientation) ? 4 : 5;
    NSInteger numberOfDrawers = self.fetchedResultsController.fetchedObjects.count;
    _numberOfPages = ceil((float)numberOfDrawers / (float)_numberOfDrawerPerPage) + 1;
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width * _numberOfPages, _scrollView.frame.size.height)];
    _pageControl.numberOfPages = _numberOfPages;
    _pageControl.currentPage = _pageControl.currentPage;
}

- (void)removeDrawerViewAtIndex:(int)index
{
    UIView *view = [_drawerViewArray objectAtIndex:index];
    [UIView animateWithDuration:0.3 animations:^{
        view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
        [_drawerViewArray removeObject:view];
        Group *group = [self.fetchedResultsController.fetchedObjects objectAtIndex:index];
        [self.managedObjectContext deleteObject:group];
        [self.fetchedResultsController performFetch:nil];
        [self updatePageControlAndScrollViewSize:[UIApplication sharedApplication].statusBarOrientation];
    }];
    
    for (int i = index + 1; i < _drawerViewArray.count; ++i) {
        ShelfDrawerView *view = [_drawerViewArray objectAtIndex:i];
        Group *group = [self.fetchedResultsController.fetchedObjects objectAtIndex:i];
        [UIView animateWithDuration:0.3 animations:^{
            [self resetDrawerViewLayout:view withIndex:i - 1];
        } completion:^(BOOL finished) {
            view.index--;
            group.index = [NSNumber numberWithInt:view.index];
        }];
    }
}

- (void)resetDrawerViewLayout:(UIView *)view withIndex:(int)index
{
    BOOL isPortrait = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    
    int drawWith = isPortrait ? 183 : 200;
    int initialOffset = isPortrait ? 65 : 65;
    int scrollViewWidth = isPortrait ? 768.0 : 1024.0;
    
    NSInteger page = index / _numberOfDrawerPerPage + 1;
    NSInteger pageOffset = index % _numberOfDrawerPerPage;
    CGFloat originX = scrollViewWidth * page + drawWith * pageOffset + initialOffset;
    [view resetOriginX:originX];
}

- (void)resetBGImageView:(CGFloat)currentWidth
{
    if (_pageControl.currentPage > 0) {
        currentWidth = _pageControl.currentPage * currentWidth;
    }
    [_shelfBGImageView resetOriginX:currentWidth - 62.0];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat screenWidth = [UIApplication screenWidth];
    if (scrollView.contentOffset.x >= screenWidth) {
        [_shelfBGImageView resetOriginX:_scrollView.contentOffset.x - 62.0];
    } else {
        [_shelfBGImageView resetOriginX:screenWidth - 62.0];
    }
    [_shelfBorderImageView resetOriginX:_scrollView.contentOffset.x];
}

#pragma mark - Public Methods
- (void)loadImages
{
    for (ShelfDrawerView *view in _drawerViewArray) {
        if (!view.imageLoaded) {
            Group *group = [self.fetchedResultsController.fetchedObjects objectAtIndex:view.index];
            [view loadImageFromURL:group.picURL completion:nil];
        }
    }
}

- (void)didHideShelf
{
    _scrollView.contentOffset = CGPointMake(_scrollView.frame.size.width, 0.0);
    _pageControl.currentPage = 1;
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
