//
//  StackViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-5-26.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "StackViewController.h"
#import "StackViewPageController.h"
#import "UIView+Resize.h"
#import "TipsViewController.h"
#import "NSUserDefaults+Addition.h"

@interface StackViewController ()
@property (nonatomic, weak) StackViewPageController *activePageViewController;

@end

@implementation StackViewController

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
    self.stackView.delegate = self;
    
    if (![NSUserDefaults hasShownStackTips]) {
        [[[TipsViewController alloc] initWithType:TipsViewControllerTypeStack] show];
        [NSUserDefaults setShownStackTips:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(stackViewSendShowBGNotification) 
                                                 name:kNotificationNameOrientationWillChange 
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)stackViewSendShowBGNotification
{
    [self.stackView sendShowBGNotification];
}

- (void)insertStackPage:(StackViewPageController *)vc
                atIndex:(int)targetIndex
           withPageType:(StackViewPageType)pageType
        pageDescription:(NSString *)pageDescription;
{
    StackViewPageController *searchResult = [self checkStackForType:pageType description:pageDescription];
    if (searchResult) {
        
        [self scrollToTargetVieController:searchResult];
        
        if (vc.loadWithPurpose) {
            searchResult.shouldShowFirst = vc.shouldShowFirst;
            [searchResult showWithPurpose];
        }
    } else {
        [self addViewController:vc atIndex:targetIndex];
    }
}

- (void)scrollToTargetVieController:(StackViewPageController *)vc
{
    if (self.activePageViewController.pageIndex != vc.pageIndex) {
        BOOL toLeft = vc.pageIndex < self.activePageViewController.pageIndex;
        for (StackViewPageController *animationVC in self.controllerStack) {
            [animationVC stackScrollingStartFromLeft:toLeft];
        }
    }
    [self.stackView scrollToTargetView:vc.view];
}


- (StackViewPageController *)checkStackForType:(StackViewPageType)pageType description:(NSString *)pageDescription
{
    StackViewPageController *result = nil;
    for (StackViewPageController *vc in self.controllerStack) {
        if (vc.pageType == pageType && [vc.pageDescription isEqualToString:pageDescription]) {
            result = vc;
        }
    }
    
    return result;
}

- (void)addViewController:(StackViewPageController *)vc 
                  atIndex:(int)targetIndex
{
    BOOL replacingOtherView = NO;
    if (self.controllerStack.count != 0) {
        while (self.controllerStack.count - 1 > targetIndex) {
            StackViewPageController *lastViewController = [self.controllerStack lastObject];
            [self.stackView removeLastView:lastViewController.view completion:^{
                [lastViewController.view removeFromSuperview];
            }];
            [lastViewController pagePopedFromStack];
            [lastViewController viewWillDisappear:NO];
            [self.controllerStack removeObject:lastViewController];
            lastViewController = nil;
            replacingOtherView = YES;
        }
    }
    
    vc.pageIndex = _controllerStack.count;
    vc.delegate = self;
    CGFloat targetHeight = self.view.frame.size.height;
    [vc.view resetHeight:targetHeight];
    
    [self.controllerStack addObject:vc];
    if (replacingOtherView) {
        StackViewPageController *animationVC = [self.controllerStack lastObject];
        [animationVC stackScrollingStartFromLeft:NO];
        if (self.activePageViewController.pageIndex == self.controllerStack.count - 2) {
            [self.activePageViewController stackScrollingStartFromLeft:NO];
        }
    } else {
        for (StackViewPageController *animationVC in self.controllerStack) {
            [animationVC stackScrollingStartFromLeft:NO];
        }
    }
    self.view.userInteractionEnabled = NO;
    BlockARCWeakSelf weakSelf = self;
    
    [self.stackView addNewPage:vc.view replacingView:replacingOtherView completion:^{
        [vc initialLoad];
        [weakSelf stackViewDidEndScrolling];
        weakSelf.view.userInteractionEnabled = YES;
    }];
}

- (void)refresh
{
    int currentPage = [self.stackView currentPage];
    if (currentPage >= 0 && currentPage <= self.controllerStack.count - 1) {
        StackViewPageController *vc = [self.controllerStack objectAtIndex:currentPage];
        [vc refresh];
    }
}

- (int)stackTopIndex
{
    return self.controllerStack.count - 1;
}

#pragma mark - Stack View Delegate

- (int)pageNumber
{
    return self.controllerStack.count;
}

- (UIView *)viewForPageIndex:(int)index
{
    if (index >= self.controllerStack.count) {
        return nil;
    }
    
    StackViewPageController *vc = [self.controllerStack objectAtIndex:index];
    return vc.view;
}

- (void)stackBecomedEmpty
{
    if ([_delegate respondsToSelector:@selector(clearStack)]) {
        [_delegate clearStack];
    }
}

- (void)deleteAllPages
{
    while (self.controllerStack.count > 0) {
        StackViewPageController *vc = [self.controllerStack lastObject];
        [vc clearPage];
        [vc.view removeFromSuperview];
        [self.controllerStack removeLastObject];
        vc = nil;
    }
    self.controllerStack = nil;
}

- (void)stackViewDidScroll
{
    [_delegate stackViewScrolledWithOffset:_stackView.scrollView.contentOffset.x width:_stackView.scrollView.contentSize.width - 384.0];
}

- (void)stackViewDidEndScrolling
{
    int currentPage = [self.stackView currentPage];
    if (currentPage >= 0 && currentPage <= self.controllerStack.count - 1) {
        [_activePageViewController setIsActive:NO];
        _activePageViewController = [self.controllerStack objectAtIndex:currentPage];
        [_activePageViewController setIsActive:YES];
    }
}

- (void)stackViewWillScroll
{
    for (StackViewPageController *animationVC in self.controllerStack) {
        [animationVC stackDidScroll];
    }
}

- (void)stackViewWillBeginDecelerating:(CGFloat)speed
{
    for (StackViewPageController *animationVC in self.controllerStack) {
        [animationVC stackScrolling:speed];
    }
}

#pragma mark - Stack View Page Controller Delegate
- (void)stackViewPage:(StackViewPageController *)vc shouldBecomeActivePageAnimated:(BOOL)animated
{
    [self.stackView scrollToTargetView:vc.view];
}

#pragma mark - Property
- (NSMutableArray *)controllerStack
{
    if (!_controllerStack) {
        _controllerStack = [[NSMutableArray alloc] init];
    }
    return _controllerStack;
}

@end
