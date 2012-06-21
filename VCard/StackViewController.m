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

@interface StackViewController ()

@end

@implementation StackViewController

@synthesize stackView = _stackView;
@synthesize controllerStack = _controllerStack;
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
    self.stackView.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addNewStackPage:)
                                                 name:kNotificationNameAddNewStackPage
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(stackViewSendShowBGNotification) 
                                                 name:kNotificationNameOrientationWillChange 
                                               object:nil];
    
    //FIXME: Debug
//    self.view.backgroundColor = [UIColor blackColor];
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

- (void)addNewStackPage:(NSNotification *)noitfication
{
    StackViewPageController *sender = noitfication.object;
    int senderIndex = sender.pageIndex;
    BOOL replacingOtherView = NO;
    while (self.controllerStack.count - 1 > senderIndex) {
        StackViewPageController *lastViewController = [self.controllerStack lastObject];
        [self.stackView removeLastView:lastViewController.view];
        [self.controllerStack removeLastObject];
        replacingOtherView = YES;
    }
    
    StackViewPageController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SelfProfileViewController"];
    vc.pageIndex = _controllerStack.count;
    vc.currentUser = self.currentUser;
    [self addViewController:vc replacingOtherView:replacingOtherView];
}

- (void)insertStackPage:(StackViewPageController *)vc atIndex:(int)targetIndex
{
    BOOL replacingOtherView = NO;
    while (self.controllerStack.count - 1 > targetIndex) {
        StackViewPageController *lastViewController = [self.controllerStack lastObject];
        [self.stackView removeLastView:lastViewController.view];
        [self.controllerStack removeLastObject];
        replacingOtherView = YES;
    }
    
    vc.pageIndex = _controllerStack.count;
    vc.currentUser = self.currentUser;
    [self addViewController:vc replacingOtherView:replacingOtherView];
}

- (void)addViewController:(StackViewPageController *)vc replacingOtherView:(BOOL)replacing
{
    [self.controllerStack addObject:vc];
    [self.stackView addNewPage:vc.view replacingView:replacing completion:^{
        [vc initialLoad];
    }];
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
    [_delegate clearStack];
}

- (void)stackViewDidScroll
{
    [_delegate stackViewScrolledWithOffset:_stackView.scrollView.contentOffset.x width:_stackView.scrollView.contentSize.width - 384.0];
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
