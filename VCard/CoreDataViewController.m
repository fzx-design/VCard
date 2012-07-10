//
//  CoreDataViewController.m
//  PushBox
//
//  Created by Xie Hasky on 11-7-24.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "CoreDataViewController.h"
#import "AppDelegate.h"
#import "User.h"
#import "NSNotificationCenter+Addition.h"

#define kStoredCurrentUserID @"StoredCurrentUserID"

static CoreDataKernal *kernalInstance = nil;

@interface CoreDataViewController()

@property (nonatomic, readonly) CoreDataKernal *kernal;

@end

@implementation CoreDataViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize fetchedResultsController = _fetchedResultsController;

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
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *currentUserID = [defaults stringForKey:kStoredCurrentUserID];
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
    User *currentUser = [User userWithID:currentUserID inManagedObjectContext:appDelegate.managedObjectContext];
    self.currentUser = currentUser;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:currentUserID forKey:kStoredCurrentUserID];
    [defaults synchronize];
}

#pragma mark -
#pragma mark Handle notifications

- (void)handleCoreChangeCurrentUserNotification:(NSNotification *)notification {
    NSString *currentUserID = notification.object;
    [self configureCurrentUserWithUserID:currentUserID];
    [NSNotificationCenter postChangeCurrentUserNotification];
}

@end
