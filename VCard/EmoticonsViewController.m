//
//  EmoticonsViewController.m
//  VCard
//
//  Created by 紫川 王 on 12-6-6.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "EmoticonsViewController.h"
#import "EmoticonsInfoReader.h"
#import <QuartzCore/QuartzCore.h>

#define SCROLL_VIEW_ROW_COUNT       3
#define SCROLL_VIEW_COLUMN_COUNT    5

@interface EmoticonsViewController ()

@end

@implementation EmoticonsViewController

@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize delegate = _delegate;

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
    [self configureBorder];
    
    [[EmoticonsInfoReader sharedReader] storePriorityLevel];
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

- (void)configureBorder {
    self.view.layer.cornerRadius = 12.0f;
    self.view.layer.shadowOffset = CGSizeMake(0, 10);
    self.view.layer.shadowRadius = 12.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowOpacity = 0.5f;
}

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
                int index = page * emoticonsPerPage + row * SCROLL_VIEW_COLUMN_COUNT + column;
                if(index >= emoticonsCount)
                    break;
                EmoticonsInfo *info = [emoticonsInfoArray objectAtIndex:index];
                UIImage *buttonImage = [UIImage imageNamed:info.imageFileName];
                EmoticonsButton *button = [[EmoticonsButton alloc] initWithFrame:CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height)];
                [button setImage:buttonImage forState:UIControlStateNormal];
                button.center = CGPointMake(scrollViewWidth * page + scrollViewWidth / SCROLL_VIEW_COLUMN_COUNT * (column + 0.5f), scrollViewHeight / SCROLL_VIEW_ROW_COUNT * (row + 0.5f));
                button.index = index;
                button.infoKeyName = info.keyName;
                [button addTarget:self action:@selector(didClickEmoticonsButton:) forControlEvents:UIControlEventTouchUpInside];
                [self.scrollView addSubview:button];
            }
        }
    }
}

#pragma mark - IBActions

- (void)didClickEmoticonsButton:(EmoticonsButton *)button {
    [self.delegate didClickEmoticonsButtonWithInfoKey:[NSString stringWithFormat:@"[%@]", button.infoKeyName]];
    [[EmoticonsInfoReader sharedReader] addEmoticonsPriorityLevelForKey:button.infoKeyName];
}

- (IBAction)didChangePageControlValue:(UIPageControl *)sender {
    NSInteger page = sender.currentPage;
    CGRect frame = self.scrollView.frame;
    frame.origin.x = page * frame.size.width;
    [self.scrollView scrollRectToVisible:frame animated:YES];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger page = fabs(scrollView.contentOffset.x) / scrollView.frame.size.width;
    self.pageControl.currentPage = page;
}

@end

@implementation EmoticonsButton

@synthesize index = _index;
@synthesize infoKeyName = _infoKeyName;

@end
