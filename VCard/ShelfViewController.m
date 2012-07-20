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
#import "SettingViewController.h"
#import "NSUserDefaults+Addition.h"

#define kShelfHeight            150.0
#define kNumberOfDrawerPerPage  5
#define kEditScrollViewOffset   5.0
#define kScrollViewBGOffset     -62.0
#define kEditButtonTextColor    [UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:170.0/255.0 alpha:1.0]
#define kDrawerViewFrameOffsetX -20.0


@implementation WBGroupInfo

@end

@interface ShelfViewController () {
    UIImageView *_shelfBGImageView;
    UIButton    *_editButton;
    NSInteger   _numberOfPages;
    NSInteger   _numberOfDrawerPerPage;
    ShelfDrawerView *_currentDrawerView;
    CGPoint     _initialPoint;
    BOOL        _editing;
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
    
    _editing = NO;
    
    [self initScrollView];
    [self setUpSettingView];
    [self setUpGroupsInfo];
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
               selector:@selector(deleteGroupWithNotification:)
                   name:kNotificationNameShouldDeleteGroup
                 object:nil];
    [center addObserver:self
               selector:@selector(didReturnToNormalTimeline)
                   name:kNotificationNameDidReturnToNormalTimeline
                 object:nil];
    [center addObserver:self
               selector:@selector(loadUserDefaults)
                   name:kNotificationNameShouldRefreshWaterflowView
                 object:nil];
    [center addObserver:self
               selector:@selector(loadUserDefaults)
                   name:kNotificationNameDidChangeFontSize
                 object:nil];
    [center addObserver:self
               selector:@selector(getGroups)
                   name:kNotificationNameShouldRefreshShelf
                 object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setUpNotifications];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void)deleteGroupWithNotification:(NSNotification *)notification
{
    Group *group = notification.object;
    [self deleteGroup:group];
}

- (void)didReturnToNormalTimeline
{
    [_currentDrawerView hideHighlightGlow];
    _currentDrawerView.enabled = YES;
    ShelfDrawerView *drawerView = [_drawerViewArray objectAtIndex:0];
    [drawerView showHighlightGlow];
    drawerView.enabled = NO;
    _currentDrawerView = drawerView;
}

#pragma mark - Group Infomation Behavior
- (void)setUpGroupsInfo
{
    [self getGroups];
    [self getTrends];
    [self getDefaultGroupImage];
}

- (void)getGroups
{
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            [Group deleteAllGroupsOfType:kGroupTypeGroup OfUser:self.currentUser.userID inManagedObjectContext:self.managedObjectContext];
            NSArray *resultArray = [client.responseJSONObject objectForKey:@"lists"];
            for (NSDictionary *dict in resultArray) {
                [Group insertGroupInfo:dict userID:self.currentUser.userID inManagedObjectContext:self.managedObjectContext];
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
            [Group deleteAllGroupsOfType:kGroupTypeTopic OfUser:self.currentUser.userID inManagedObjectContext:self.managedObjectContext];
            NSArray *resultArray = client.responseJSONObject;
            for (NSDictionary *dict in resultArray) {
                Group *group = [Group insertTopicInfo:dict userID:self.currentUser.userID inManagedObjectContext:self.managedObjectContext];
                [self getPicURLForTopic:group];
            }
        }
        
        [self.managedObjectContext processPendingChanges];
        [self.fetchedResultsController performFetch:nil];
        
        [self performSelector:@selector(setUpScrollView) withObject:nil afterDelay:0.001];
    }];
    
    [client getTrends];
}

- (void)getDefaultGroupImage
{
    WBClient *client = [WBClient client];
    
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            NSArray *array = client.responseJSONObject;
            for (NSDictionary *dict in array) {
                if ([dict isKindOfClass:[NSDictionary class]]) {
                    NSString *imageURL = [dict objectForKey:@"avatar_large"];
                    Group *group = [Group setUpDefaultGroupImageWithDefaultURL:imageURL UserID:self.currentUser.userID inManagedObjectContext:self.managedObjectContext];
                    ShelfDrawerView *drawerView = [self.drawerViewArray objectAtIndex:group.index.intValue];
                    [drawerView loadImageFromURL:imageURL completion:nil];
                    break;
                }
            }
        }
    }];
    
    [client getUserBilateral];
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

- (void)configureRequest:(NSFetchRequest *)request
{
    NSSortDescriptor *col1SD = [[NSSortDescriptor alloc] initWithKey:@"type" ascending:YES];
    NSSortDescriptor *col2SD = [[NSSortDescriptor alloc] initWithKey:@"groupID" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:col1SD, col2SD, nil];
    
    request.sortDescriptors = sortDescriptors;
    request.predicate = [NSPredicate predicateWithFormat:@"groupUserID == %@", self.currentUser.userID];
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
        [view resetOriginX:originX + kDrawerViewFrameOffsetX];
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
    _fontSizeSlider.maximumValue = 1.0;
    _fontSizeSlider.minimumValue = 0.0;
    _fontSizeSlider.value = 0.0;
    
    if ([NSUserDefaults currentFontSize] == (CGFloat)SettingOptionFontSizeSmall) {
        _fontSizeSlider.value = 0.0;
    } else if ([NSUserDefaults currentFontSize] == (CGFloat)SettingOptionFontSizeNormal) {
        _fontSizeSlider.value = 0.5;
    } else {
        _fontSizeSlider.value = 1.0;
    }
    
    [ThemeResourceProvider configButtonBrown:_detailSettingButton];
    [self loadUserDefaults];
}

- (void)loadUserDefaults
{
    _switchToPicButton.selected = [NSUserDefaults isPictureEnabled];
    _switchToTextButton.selected = ![NSUserDefaults isPictureEnabled];
    _switchToPicButton.userInteractionEnabled = ![NSUserDefaults isPictureEnabled];
    _switchToTextButton.userInteractionEnabled = [NSUserDefaults isPictureEnabled];
    if ([NSUserDefaults currentFontSize] == (CGFloat)SettingOptionFontSizeSmall) {
        _fontSizeSlider.value = 0.0;
    } else if ([NSUserDefaults currentFontSize] == (CGFloat)SettingOptionFontSizeNormal) {
        _fontSizeSlider.value = 0.5;
    } else {
        _fontSizeSlider.value = 1.0;
    }
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
    [_scrollView resetWidth:[UIApplication screenWidth]];
    [_scrollView resetHeight:kShelfHeight];
    _scrollView.contentOffset = CGPointMake(_scrollView.frame.size.width, 0.0);
    ShelfBackgroundView *view = (ShelfBackgroundView *)self.view;
    view.scrollViewReference = (ShelfScrollView *)_scrollView; 
    
    _shelfBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-62.0, 0.0, 1064.0, 150.0)];
    _shelfBGImageView.image = [UIImage imageNamed:@"shelf_bg.png"];
    _shelfBGImageView.contentMode = UIViewContentModeLeft;
    _shelfBGImageView.autoresizingMask = UIViewAutoresizingNone;
    _shelfBGImageView.userInteractionEnabled = NO;
    [_shelfBGImageView resetOriginX:_scrollView.frame.size.width + kScrollViewBGOffset];
    [_scrollView insertSubview:_shelfBGImageView belowSubview:_shelfBorderImageView];
    
    _editButton = [[UIButton alloc] initWithFrame:CGRectMake(5.0, 7.0, 50.0, 30.0)];
    [ThemeResourceProvider configButtonBrown:_editButton];
    [_editButton addTarget:self action:@selector(didClickEditButton:) forControlEvents:UIControlEventTouchUpInside];
    [_editButton resetOriginX:_scrollView.frame.size.width + kEditScrollViewOffset];
    [_editButton setTitle:@"编辑" forState:UIControlStateNormal];
    [_editButton setTitleColor:kEditButtonTextColor forState:UIControlStateNormal];
    [_editButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _editButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
    [_scrollView insertSubview:_editButton aboveSubview:_shelfBGImageView];
    
    [_shelfBorderImageView resetWidth:1024.0];
    _coverView.alpha = 1.0;
    
    [self setUpScrollView];
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
    
    if (_currentDrawerView == nil) {
        _currentDrawerView = [_drawerViewArray objectAtIndex:0];
        [_currentDrawerView showHighlightGlow];
        _currentDrawerView.enabled = NO;
    } else {
        ShelfDrawerView *drawerView = [_drawerViewArray objectAtIndex:_currentDrawerView.index];
        [drawerView showHighlightGlow];
        drawerView.enabled = NO;
        _currentDrawerView = nil;
        _currentDrawerView = drawerView;
    }
    
    
    [self resetContentLayout:[UIApplication sharedApplication].statusBarOrientation];
    [self willRotateToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:0.3];
    [self didRotateFromInterfaceOrientation:[UIApplication currentOppositeInterface]];
}

#pragma mark - Drawer Behavior
- (void)createDrawerViewWithGroup:(Group *)group index:(int)index
{
    ShelfDrawerView *drawerView = [[ShelfDrawerView alloc] initWithFrame:CGRectMake(0.0, 20.0, 105, 105.0)
                                                               topicName:group.name
                                                                  picURL:group.picURL
                                                                   index:index
                                                                    type:group.type.intValue
                                                                   empty:group.count.intValue == 0];
    
    drawerView.adjustsImageWhenHighlighted = YES;
    [drawerView addTarget:self action:@selector(changeCastViewSource:) forControlEvents:UIControlEventTouchUpInside];
    drawerView.delegate = self;
    [_scrollView addSubview:drawerView];
    [_drawerViewArray addObject:drawerView];
    [drawerView appearWithDuration:0.3];
    [self resetDrawerViewLayout:drawerView withIndex:index];
    
    group.index = [NSNumber numberWithInt:index];
    index++;
}

- (void)changeCastViewSource:(UIButton *)sender
{
    if (_editing) {
        return;
    }
    
    ShelfDrawerView *view = (ShelfDrawerView *)sender;
    if (![view isEqual:_currentDrawerView]) {
        view.enabled = NO;
        _currentDrawerView.enabled = YES;
        [_currentDrawerView setSelected:NO];
        [view setSelected:YES];
        _currentDrawerView = view;
        
        if (self.fetchedResultsController.fetchedObjects.count > view.index) {
            Group *group = [self.fetchedResultsController.fetchedObjects objectAtIndex:view.index];
            
            NSString *type = [NSString stringWithFormat:@"%d",group.type.intValue];
            NSString *name = group.name;
            NSString *groupID = group.groupID;
            if (type.intValue == kGroupTypeTopic) {
                name = [NSString stringWithFormat:@"#%@#", name];
                groupID = group.name;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldChangeCastviewDataSource
                                                                object:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                        name, kNotificationObjectKeyDataSourceDescription,
                                                                        type, kNotificationObjectKeyDataSourceType,
                                                                        groupID, kNotificationObjectKeyDataSourceID, nil]];
        } else {
            NSLog(@"Core Data TableView Controller Error - Shelf change source");
        }
    }
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
    if (_currentDrawerView.index == index) {
        [_currentDrawerView hideHighlightGlow];
        ShelfDrawerView *drawerView = [_drawerViewArray objectAtIndex:0];
        [drawerView showHighlightGlow];
        drawerView.enabled  = NO;
        _currentDrawerView = drawerView;
    }
    
    UIView *view = [_drawerViewArray objectAtIndex:index];
    [UIView animateWithDuration:0.3 animations:^{
        view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
        [_drawerViewArray removeObject:view];
        if (self.fetchedResultsController.fetchedObjects.count > index) {
            Group *group = [self.fetchedResultsController.fetchedObjects objectAtIndex:index];
            [self.managedObjectContext deleteObject:group];
            [self.fetchedResultsController performFetch:nil];
            [self updatePageControlAndScrollViewSize:[UIApplication sharedApplication].statusBarOrientation];
        } else {
            NSLog(@"Core Data TableView Controller Error - Shelf remove");
        }
    }];
    
    for (int i = index + 1; i < _drawerViewArray.count; ++i) {
        if (self.fetchedResultsController.fetchedObjects.count > i) {
            ShelfDrawerView *view = [_drawerViewArray objectAtIndex:i];
            Group *group = [self.fetchedResultsController.fetchedObjects objectAtIndex:i];
            [UIView animateWithDuration:0.3 animations:^{
                [self resetDrawerViewLayout:view withIndex:i - 1];
            } completion:^(BOOL finished) {
                view.index--;
                group.index = [NSNumber numberWithInt:view.index];
            }];
        } else {
            NSLog(@"Core Data TableView Controller Error - Shelf relayout");
        }
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
    [view resetOriginX:originX + kDrawerViewFrameOffsetX];
}

- (void)resetBGImageView:(CGFloat)currentWidth
{
    if (_pageControl.currentPage > 0) {
        currentWidth = _pageControl.currentPage * currentWidth;
    }
    [_shelfBGImageView resetOriginX:currentWidth + kScrollViewBGOffset];
    [_editButton resetOriginX:currentWidth + kEditScrollViewOffset];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat screenWidth = [UIApplication screenWidth];
    if (scrollView.contentOffset.x >= screenWidth) {
        [_shelfBGImageView resetOriginX:_scrollView.contentOffset.x + kScrollViewBGOffset];
        [_editButton resetOriginX:_scrollView.contentOffset.x + kEditScrollViewOffset];
    } else {
        [_shelfBGImageView resetOriginX:screenWidth + kScrollViewBGOffset];
        [_editButton resetOriginX:screenWidth + kEditScrollViewOffset];
    }
    [_shelfBorderImageView resetOriginX:_scrollView.contentOffset.x];
}

#pragma mark - Public Methods
- (void)loadImages
{
    for (ShelfDrawerView *view in _drawerViewArray) {
        if (!view.imageLoaded) {
            if (self.fetchedResultsController.fetchedObjects.count > view.index) {
                Group *group = [self.fetchedResultsController.fetchedObjects objectAtIndex:view.index];
                [view loadImageFromURL:group.picURL completion:nil];
            } else {
                NSLog(@"Core Data TableView Controller Error - Shelf load image");
            }
        }
    }
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger page = fabs(scrollView.contentOffset.x) / scrollView.frame.size.width;
    _pageControl.currentPage = page;
}

#pragma mark - ShelfDrawerViewDelegate
- (void)didClickDeleteButtonAtIndex:(int)index
{
    if (self.fetchedResultsController.fetchedObjects.count > index) {
        Group *group = [self.fetchedResultsController.fetchedObjects objectAtIndex:index];
        [self deleteGroup:group];
    } else {
        NSLog(@"Core Data TableView Controller Error - Shelf");
    }
}

- (void)deleteGroup:(Group *)group
{
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        [self removeDrawerViewAtIndex:group.index.intValue];
        [Group deleteGroupWithGroupID:group.groupID userID:self.currentUser.userID inManagedObjectContext:self.managedObjectContext];
    }];
    
    if (group.type.intValue == kGroupTypeTopic) {
        [client unfollowTrend:group.groupID];
    } else if (group.type.intValue == kGroupTypeGroup) {
        [client deleteGroup:group.groupID];
    }
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
    CGFloat prevFontSize = [NSUserDefaults currentFontSize];
    __block CGFloat currentFontSize = prevFontSize;
    if ([sender isEqual:_fontSizeSlider]) {
        [UIView animateWithDuration:0.3 animations:^{
            if (sender.value < 0.3) {
                sender.value = 0.0;
                currentFontSize = SettingOptionFontSizeSmall;
            } else if (sender.value < 0.7) {
                sender.value = 0.5;
                currentFontSize = SettingOptionFontSizeNormal;
            } else {
                sender.value = 1.0;
                currentFontSize = SettingOptionFontSizeBig;
            }
        } completion:^(BOOL finished) {
            if (currentFontSize != prevFontSize) {
                [NSUserDefaults setCurrentFontSize:currentFontSize];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameDidChangeFontSize object:nil];
            }
        }];
    }
}

- (IBAction)didClickDetialSettingButton:(UIButton *)sender
{
    [[[SettingViewController alloc] init] show];
}

- (IBAction)didClickSwitchModeButton:(UIButton *)sender
{
    BOOL switchToPicButtonClicked = [sender isEqual:_switchToPicButton];
    
    _switchToPicButton.selected = switchToPicButtonClicked;
    _switchToPicButton.userInteractionEnabled = !switchToPicButtonClicked;
    _switchToTextButton.selected = !switchToPicButtonClicked;
    _switchToTextButton.userInteractionEnabled = switchToPicButtonClicked;
    
    [NSUserDefaults setPictureEnabled:switchToPicButtonClicked];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldRefreshWaterflowView object:nil];
}

- (IBAction)didChangePageControlValue:(UIPageControl *)sender
{
    NSInteger page = sender.currentPage;
    CGRect frame = _scrollView.frame;
    frame.origin.x = page * frame.size.width;
    [_scrollView scrollRectToVisible:frame animated:YES];
}

- (void)didClickEditButton:(UIButton *)sender
{
    _editing = !_editing;
    if (_editing) {
        for (ShelfDrawerView *view in _drawerViewArray) {
            view.editing = _editing;
            [view showDeleteButton];
        }
        [_editButton setTitle:@"完成" forState:UIControlStateNormal];
    } else {
        for (ShelfDrawerView *view in _drawerViewArray) {
            view.editing = _editing;
            [view hideDeleteButton];
        }
        [_editButton setTitle:@"编辑" forState:UIControlStateNormal];
    }
}

- (void)exitEditMode
{
    _editing = NO;
    for (ShelfDrawerView *view in _drawerViewArray) {
        view.editing = _editing;
        [view hideDeleteButton];
    }
    [_editButton setTitle:@"编辑" forState:UIControlStateNormal];
}


@end
