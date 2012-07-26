//
//  GroupInfoTableViewController.m
//  VCard
//
//  Created by 海山 叶 on 12-7-20.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "GroupInfoTableViewController.h"
#import "UIView+Resize.h"
#import "Group.h"
#import "WBClient.h"

@interface GroupInfoTableViewController () {
    NSFetchedResultsController *_fetchedResultsController;
}

@end

@implementation GroupInfoTableViewController

static UIPopoverController *popoverController = nil;
static GroupInfoTableViewController *groupInfoTableViewController = nil;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.fetchedResultsController performFetch:nil];
    _chosenDictionary = [[NSMutableDictionary alloc] initWithCapacity:20];
    for (Group *group in self.fetchedResultsController.fetchedObjects) {
        [_chosenDictionary setObject:@(NO) forKey:group.name];
    }
    
//    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
//    [center add];
    
    [self loadFriendGroupInfo];
}

- (void)loadFriendGroupInfo
{
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        if (!client.hasError) {
            NSDictionary *result = client.responseJSONObject;
            for (NSDictionary *objectDict in result.objectEnumerator) {
                NSArray *dictArray = [objectDict objectForKey:@"lists"];
                for (NSDictionary *dict in dictArray) {
                    [_chosenDictionary setObject:@(YES) forKey:[dict objectForKey:@"name"]];
                }
            }
            _originChosenDictionary = [NSDictionary dictionaryWithDictionary:_chosenDictionary];
            [self.tableView reloadData];
        }
    }];
    [client getGroupInfoOfUser:self.userID];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.chosenDictionary = nil;
    self.userID = nil;
}

- (void)configureRequest:(NSFetchRequest *)request
{
    NSSortDescriptor *sortDescriptor;
    
    sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
    request.sortDescriptors = @[sortDescriptor];
    request.predicate = [NSPredicate predicateWithFormat:@"groupUserID == %@ && type = %@", self.currentUser.userID, @kGroupTypeGroup];
    request.entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (self.fetchedResultsController.fetchedObjects.count > indexPath.row) {
        Group *group = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
        cell.textLabel.text = group.name;
        if ([[_chosenDictionary objectForKey:group.name] boolValue]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}

- (NSString *)customCellClassNameForIndex:(NSIndexPath *)indexPath
{
    return @"GroupInfoTableViewCell";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    BOOL followed = [[_chosenDictionary objectForKey:cell.textLabel.text] boolValue];
    [_chosenDictionary setObject:[NSNumber numberWithBool:!followed] forKey:cell.textLabel.text];
    
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

#pragma mark - Popover method

+ (void)showGroupInfoOfUser:(NSString *)userID fromRect:(CGRect)rect inView:(UIView *)view
{
    groupInfoTableViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:NULL] instantiateViewControllerWithIdentifier:@"GroupInfoTableViewController"];
    groupInfoTableViewController.userID = userID;
    [groupInfoTableViewController.view resetSize:CGSizeMake(400.0, 300.0)];
    
    UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:groupInfoTableViewController];
    groupInfoTableViewController.title = @"所在分组";
    
    popoverController = [[UIPopoverController alloc] initWithContentViewController:navCon];
    popoverController.delegate = groupInfoTableViewController;
    [popoverController presentPopoverFromRect:rect
                                       inView:view
                     permittedArrowDirections:UIPopoverArrowDirectionUp
                                     animated:YES];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    __block int pendingCount = 0;
    
    for (Group *group in self.fetchedResultsController.fetchedObjects) {
        BOOL originalValue = [[_originChosenDictionary objectForKey:group.name] boolValue];
        BOOL currentValue = [[_chosenDictionary objectForKey:group.name] boolValue];
        if (originalValue != currentValue) {
            pendingCount++;
            
            WBClient *client = [WBClient client];
            [client setCompletionBlock:^(WBClient *client) {
                pendingCount--;
                if (pendingCount <= 0) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldRefreshShelf object:nil];
                }
            }];
            if (currentValue) {
                [client addUser:self.userID toGroup:group.groupID];
            } else {
                [client removeUser:self.userID fromGroup:group.groupID];
            }
        }
    }
}

@end
