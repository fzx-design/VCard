//
//  CastViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-4-18.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "CastViewController.h"
#import "ResourceList.h"
#import "WBClient.h"
#import "Status.h"
#import "User.h"


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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        [self loadData];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kRLCastViewBGUnit]];
    [self.fetchedResultsController performFetch:nil];
    
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

#pragma mark - Data Methods
- (void)loadData
{
    WBClient *client = [WBClient client];
    
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            NSArray *dictArray = client.responseJSONObject;
            for (NSDictionary *dict in dictArray) {
                Status *newStatus = nil;
                newStatus = [Status insertStatus:dict inManagedObjectContext:self.managedObjectContext];
                [self.currentUser addFriendsStatusesObject:newStatus];  
            }
            
            [self.managedObjectContext processPendingChanges];
            [self.fetchedResultsController performFetch:nil];
            [self.waterflowView reloadData];
        }
    }];
    
    [client getFriendsTimelineSinceID:nil 
                                maxID:nil 
                       startingAtPage:1 
                                count:20 
                              feature:0];
}


#pragma mark - CoreDataTableViewController methods

- (void)configureRequest:(NSFetchRequest *)request
{
    NSSortDescriptor *sortDescriptor;
	
    sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"statusID" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    request.entity = [NSEntityDescription entityForName:@"Status" inManagedObjectContext:self.managedObjectContext];
 
    request.predicate = [NSPredicate predicateWithFormat:@"isFriendsStatusOf == %@", self.currentUser];
                  
}

- (NSString *)customCellClassName
{
    return @"CardTableViewCell";
}


#pragma mark - WaterflowDataSource

- (WaterflowCell*)flowView:(WaterflowView *)flowView_ cellForLayoutUnit:(WaterflowLayoutUnit *)layoutUnit
{
    static NSString *CellIdentifier = @"CardTableViewCell";
	WaterflowCell *cell = [flowView_ dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if(cell == nil) {
		cell = [[WaterflowCell alloc] initWithReuseIdentifier:CellIdentifier currentUser:self.currentUser];
		cell.cardViewController.currentUser = self.currentUser;
	}
    
    Status *targetStatus = (Status*)[self.fetchedResultsController.fetchedObjects objectAtIndex:layoutUnit.dataIndex];
    [cell.cardViewController configureCardWithStatus:targetStatus imageHeight:layoutUnit.imageHeight];

	return cell;
    
}

- (int)numberOfObjectsInSection
{
    return self.fetchedResultsController.fetchedObjects.count;
}

- (CGFloat)heightForObjectAtIndex:(int)index_ withImageHeight:(NSInteger)imageHeight_
{
//    NSString *string = [self randomString:index_];
//    CGSize expectedLabelSize = [string sizeWithFont:[UIFont boldSystemFontOfSize:17.0f]                       
//                                  constrainedToSize:MaxCardSize 
//                                      lineBreakMode:UILineBreakModeCharacterWrap];
//#warning !!!
    
    
    
    return [CardViewController heightForStatus:(Status *)[self.fetchedResultsController.fetchedObjects objectAtIndex:index_] andImageHeight:imageHeight_];
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
