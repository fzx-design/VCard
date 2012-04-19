//
//  CastViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-4-18.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "CastViewController.h"

@interface CastViewController ()

@end

@implementation CastViewController

@synthesize waterflowView = _waterflowView;

#pragma mark - LifeCycle
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
	// Do any additional setup after loading the view.
    [self setUpWaterflowView];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Initializing Methods
- (void)setUpWaterflowView
{
    self.waterflowView.flowdatasource = self;
    self.waterflowView.flowdelegate = self;
    
    [self.waterflowView reloadData];
}

#pragma mark - WaterflowDataSource

- (NSInteger)numberOfColumnsInFlowView:(WaterflowView *)flowView
{
    return 2;
}

- (NSInteger)flowView:(WaterflowView *)flowView numberOfRowsInColumn:(NSInteger)column
{
    return 6;
}

- (WaterflowCell*)flowView:(WaterflowView *)flowView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
	WaterflowCell *cell = [flowView_ dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if(cell == nil)
	{
		cell  = [[WaterflowCell alloc] initWithReuseIdentifier:CellIdentifier currentUser:self.currentUser];
		cell.cardViewController.currentUser = self.currentUser;
//		AsyncImageView *imageView = [[AsyncImageView alloc] initWithFrame:CGRectZero];
//		[cell addSubview:imageView];
//        imageView.contentMode = UIViewContentModeScaleToFill;
//		imageView.layer.borderColor = [[UIColor whiteColor] CGColor];
//		imageView.layer.borderWidth = 1;
//		[imageView release];
//		imageView.tag = 1001;
	}
	
//	float height = [self flowView:nil heightForRowAtIndexPath:indexPath];
    CGRect frame = cell.frame;
    frame.size.height = 800;
    cell.frame = frame;
	
//	AsyncImageView *imageView  = (AsyncImageView *)[cell viewWithTag:1001];
//	imageView.frame = CGRectMake(0, 0, self.view.frame.size.width / 3, height);
//    [imageView loadImage:[self.imageUrls objectAtIndex:(indexPath.row + indexPath.section) % 5]];
//	
	return cell;
    
}

#pragma mark-
#pragma mark- WaterflowDelegate

-(CGFloat)flowView:(WaterflowView *)flowView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
	float height = 0;
	switch ((indexPath.row + indexPath.section )  % 5) {
		case 0:
			height = 127;
			break;
		case 1:
			height = 100;
			break;
		case 2:
			height = 87;
			break;
		case 3:
			height = 114;
			break;
		case 4:
			height = 140;
			break;
		case 5:
			height = 158;
			break;
		default:
			break;
	}
	
	height += indexPath.row + indexPath.section;
	
	return 600;
    
}

- (void)flowView:(WaterflowView *)flowView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"did select at %@",indexPath);
}

@end
