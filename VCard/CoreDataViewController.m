//
//  CoreDataViewController.m
//  PushBox
//
//  Created by Xie Hasky on 11-7-24.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "CoreDataViewController.h"
#import "AppDelegate.h"
#import "NSNotificationCenter+Addition.h"
#import "NSUserDefaults+Addition.h"
#import "WBClient.h"
#import "UnreadReminder.h"
#import "SettingInfoReader.h"

static CoreDataKernal *kernalInstance = nil;

@interface CoreDataViewController()

@property (nonatomic, readonly) CoreDataKernal *kernal;

@end

@implementation CoreDataViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize fetchedResultsController = _fetchedResultsController;

#pragma mark - CoreData methods

- (void)configureRequest:(NSFetchRequest *)request
{
    
}

- (NSManagedObjectContext*)managedObjectContext
{
    if (_managedObjectContext == nil) {
        AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        _managedObjectContext = delegate.managedObjectContext;
    }
    return _managedObjectContext;
}

#pragma mark - Logic methods

- (CoreDataKernal *)kernal {
    return [CoreDataKernal getKernalInstance];
}

- (User *)currentUser {
    return [CoreDataViewController getCurrentUser];
}

+ (User *)getCurrentUser {
    return [CoreDataKernal getKernalInstance].currentUser;
}

#pragma mark -

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [self configureRequest:fetchRequest];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	[self.fetchedResultsController performFetch:NULL];
    
    return _fetchedResultsController;
}

@end

@implementation CoreDataKernal

@synthesize currentUser = _currentUser;

- (id)init {
    self = [super init];
    if(self) {
        NSString *currentUserID = [NSUserDefaults getCurrentUserID];
        [self configureCurrentUserWithUserID:currentUserID];
        [NSNotificationCenter registerCoreChangeCurrentUserNotificationWithSelector:@selector(handleCoreChangeCurrentUserNotification:) target:self];
    }
    return self;
}

+ (CoreDataKernal *)getKernalInstance {
    if(kernalInstance == nil) {
        kernalInstance = [[CoreDataKernal alloc] init];
    }
    return kernalInstance;
}

- (void)configureCurrentUserWithUserID:(NSString *)currentUserID {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    User *currentUser = [User userWithID:currentUserID inManagedObjectContext:appDelegate.managedObjectContext withOperatingObject:kCoreDataIdentifierDefault];
    self.currentUser = currentUser;
    
    NSLog(@"configure current user name %@", currentUser.screenName);
    
    [NSUserDefaults setCurrentUserID:currentUser.userID];
    
    [UnreadReminder initializeWithCurrentUser:currentUser];
    
    if(self.currentUser == nil) {
        [[WBClient client] logOut];
    }
}

- (void)refreshTeamMemberFollowStatus {
    SettingInfoReader *reader = [SettingInfoReader sharedReader];
    NSArray *teamMemberArray = [reader getTeamMemberIDArray];
    for(NSString *teamMemberID in teamMemberArray) {
        WBClient *client = [WBClient client];
        [client setCompletionBlock:^(WBClient *client) {
            NSDictionary *userDict = client.responseJSONObject;
            AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            [User insertUser:userDict inManagedObjectContext:delegate.managedObjectContext withOperatingObject:kCoreDataIdentifierDefault];
        }];
        [client getUser:teamMemberID];
    }
}

#pragma mark -
#pragma mark Handle notifications

- (void)handleCoreChangeCurrentUserNotification:(NSNotification *)notification {
    NSString *currentUserID = notification.object;
    [self configureCurrentUserWithUserID:currentUserID];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameShouldSaveContext object:nil];
    [NSNotificationCenter postChangeCurrentUserNotification];
    
    [self refreshTeamMemberFollowStatus];
}

@end
