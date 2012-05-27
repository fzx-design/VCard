//
//  StackViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-5-26.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "StackViewController.h"
#import "StackViewPageController.h"

@interface StackViewController ()

@end

@implementation StackViewController

@synthesize stackView = _stackView;
@synthesize controllerStack = _controllerStack;

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
    [[NSNotificationCenter defaultCenter]  addObserver:self
                                              selector:@selector(addNewStackPage:)
                                                  name:kNotificationNameAddNewStackPage
                                                object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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
    
    StackViewPageController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"StackViewPageController"];
    vc.pageIndex = _controllerStack.count;
    [self addViewController:vc replacingOtherView:replacingOtherView];
}

- (void)addViewController:(UIViewController *)viewController replacingOtherView:(BOOL)replacing
{
    [self.controllerStack addObject:viewController];
    [self.stackView addNewPage:viewController.view replacingView:replacing];
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

#pragma mark - Property

- (StackView *)stackView
{
    if (!_stackView) {
        _stackView = [[StackView alloc] initWithFrame:self.view.bounds];
        _stackView.delegate = self;
        [self.view addSubview:_stackView];
    }
    return _stackView;
}

- (NSMutableArray *)controllerStack
{
    if (!_controllerStack) {
        _controllerStack = [[NSMutableArray alloc] init];
    }
    return _controllerStack;
}

@end
