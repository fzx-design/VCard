//
//  ShelfViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-7-2.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "ShelfViewController.h"
#import "UIView+Resize.h"

#define kShelfHeight 149.0

@interface ShelfViewController () {
    UIImageView *_shelfBGImageView;
    UIImageView *_shelfEdgeImageView;
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
    [self setUpScrollView];
    [self setUpSettingView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
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
    [self resetSettingViewLayout:toInterfaceOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGFloat toWidth = UIInterfaceOrientationIsPortrait(fromInterfaceOrientation) ? 1024 : 768;
    [_scrollView resetWidth:toWidth];
}

- (void)resetContentSize:(UIInterfaceOrientation)orientation
{
    CGFloat toWidth = UIInterfaceOrientationIsPortrait(orientation) ? 768 : 1024;
    CGFloat fromWidth = UIInterfaceOrientationIsPortrait(orientation) ? 1024 : 768;
    NSInteger page = _scrollView.contentOffset.x / fromWidth;
    _scrollView.contentSize = CGSizeMake(toWidth * 2, kShelfHeight);
    _scrollView.contentOffset = CGPointMake(page * toWidth, 0.0);
    
    [self resetBGImageView:toWidth];
}

- (void)resetSettingViewLayout:(UIInterfaceOrientation)orientation
{
//    CGFloat center = UIInterfaceOrientationIsPortrait(orientation) ? 384.0 : 512.0;
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
    [_brightnessSlider setThumbImage:[UIImage imageNamed:@"motions_slider_thumb_vertical.png"] forState:UIControlStateNormal];
	[_brightnessSlider setThumbImage:[UIImage imageNamed:@"motions_slider_thumb_vertical.png"] forState:UIControlStateHighlighted];
	[_brightnessSlider setMinimumTrackImage:[UIImage imageNamed:@"transparent.png"] forState:UIControlStateNormal];
	[_brightnessSlider setMaximumTrackImage:[UIImage imageNamed:@"transparent.png"] forState:UIControlStateNormal];
    
    [_fontSizeSlider setThumbImage:[UIImage imageNamed:@"slider_font_thumb.png"] forState:UIControlStateNormal];
	[_fontSizeSlider setThumbImage:[UIImage imageNamed:@"slider_font_thumb.png"] forState:UIControlStateHighlighted];
	[_fontSizeSlider setMinimumTrackImage:[UIImage imageNamed:@"transparent.png"] forState:UIControlStateNormal];
	[_fontSizeSlider setMaximumTrackImage:[UIImage imageNamed:@"transparent.png"] forState:UIControlStateNormal];
    
    [ThemeResourceProvider configButtonBrown:_detailSettingButton];
    _switchToPicButton.selected = YES;
    _switchToTextButton.selected = NO;
}

#pragma mark - Scroll View Behavior
- (void)setUpScrollView
{
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width * 2, _scrollView.frame.size.height)];
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delegate = self;
    _scrollView.contentOffset = CGPointMake(_scrollView.frame.size.width, 0.0);
    [_scrollView resetSize:self.view.bounds.size];
    ShelfBackgroundView *view = (ShelfBackgroundView *)self.view;
    view.scrollViewReference = (ShelfScrollView *)_scrollView;
    
    _shelfEdgeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 62.0, 136.0)];
    _shelfEdgeImageView.image = [UIImage imageNamed:@"shelf_wood_edge.png"];
    _shelfEdgeImageView.contentMode = UIViewContentModeTop;
    _shelfEdgeImageView.autoresizingMask = UIViewAutoresizingNone;
    _shelfEdgeImageView.userInteractionEnabled = NO;
    [_shelfEdgeImageView resetOriginX:_scrollView.frame.size.width - _shelfEdgeImageView.frame.size.width];
    [_scrollView addSubview:_shelfEdgeImageView];
    
    _shelfBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 7.0, 1024.0, 136.0)];
    _shelfBGImageView.image = [UIImage imageNamed:@"shelf_bg.png"];
    _shelfBGImageView.contentMode = UIViewContentModeLeft;
    _shelfBGImageView.autoresizingMask = UIViewAutoresizingNone;
    _shelfBGImageView.userInteractionEnabled = NO;
    [_shelfBGImageView resetOriginX:_scrollView.frame.size.width];
    [_scrollView addSubview:_shelfBGImageView];
}

- (void)resetBGImageView:(CGFloat)currentWidth
{
    [_shelfEdgeImageView resetOriginX:currentWidth - _shelfEdgeImageView.frame.size.width];
    [_shelfBGImageView resetOriginX:currentWidth];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x >= _scrollView.frame.size.width) {
        [_shelfBGImageView resetOriginX:_scrollView.contentOffset.x];
//        [_shelfEdgeImageView resetOriginX:_scrollView.contentOffset.x];
    } else {
        [_shelfBGImageView resetOriginX:_scrollView.frame.size.width];
//        [_shelfEdgeImageView resetOriginX:_scrollView.contentOffset.x];
    }
}

@end
