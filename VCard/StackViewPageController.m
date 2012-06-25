//
//  StackViewPageController.m
//  VCard
//
//  Created by 海山 叶 on 12-5-26.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "StackViewPageController.h"
#import "UIView+Resize.h"

@interface StackViewPageController ()

@end

@implementation StackViewPageController

@synthesize pageIndex = _pageIndex;
@synthesize backgroundView = _backgroundView;

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
    
    
    _topShadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 384.0, 10.0)];
    _topShadowImageView.image = [UIImage imageNamed:kRLStackTableViewShadow];
    
    // Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

//To be overloaded
- (void)initialLoad
{
    
}

//To be overloaded
- (void)stackScrolling
{
    
}

//To be overloaded
- (void)stackScrollingStart
{
    
}

//To be overloaded
- (void)stackScrollingEnd
{
    
}

//To be overloaded
- (void)pagePopedFromStack
{
    
}

//To be overloaded
- (void)refresh
{
    
}



@end
