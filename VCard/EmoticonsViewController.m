//
//  EmoticonsViewController.m
//  VCard
//
//  Created by 紫川 王 on 12-6-6.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "EmoticonsViewController.h"
#import "EmoticonsInfoReader.h"

#define SCROLL_VIEW_ROW_COUNT       3
#define SCROLL_VIEW_COLUMN_COUNT    5

@interface EmoticonsViewController ()

@end

@implementation EmoticonsViewController

@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;

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
    // Do any additional setup after loading the view from its nib.
    [self configureScrollView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.scrollView = nil;
    self.pageControl = nil;
}

#pragma mark - UI methods

- (void)configureScrollView {
    NSInteger emoticonsPerPage = SCROLL_VIEW_ROW_COUNT * SCROLL_VIEW_COLUMN_COUNT;
    EmoticonsInfoReader *reader = [EmoticonsInfoReader sharedReader];
    NSArray *emoticonsInfoArray = [reader emoticonsInfoArray];
    NSInteger emoticonsCount = emoticonsInfoArray.count;
    NSInteger pageCount = ceilf((float)emoticonsCount / (float)emoticonsPerPage);
    CGFloat scrollViewWidth = self.scrollView.frame.size.width;
    CGFloat scrollViewHeight = self.scrollView.frame.size.height;
    self.scrollView.contentSize = CGSizeMake(pageCount * scrollViewWidth, scrollViewHeight);
    
    self.pageControl.numberOfPages = pageCount;

    for(int page = 0; page < pageCount; page++) {
        for(int row = 0; row < SCROLL_VIEW_ROW_COUNT; row++) {
            for(int column = 0; column < SCROLL_VIEW_COLUMN_COUNT; column++) {
                int index = page * emoticonsPerPage + row * SCROLL_VIEW_ROW_COUNT + column;
                if(index >= emoticonsCount)
                    break;
                EmoticonsInfo *info = [emoticonsInfoArray objectAtIndex:index];
                UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:info.imageFileName]];
                imageView.center = CGPointMake(scrollViewWidth * page + scrollViewWidth / SCROLL_VIEW_COLUMN_COUNT * (column + 0.5f), scrollViewHeight / SCROLL_VIEW_ROW_COUNT * (row + 0.5f));
                
                [self.scrollView addSubview:imageView];
            }
        }
    }
}

@end
