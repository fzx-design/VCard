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

@implementation CoreDataViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize currentUser = _currentUser;

- (void)setCurrentUser:(User *)currentUser
{
    if (_currentUser != currentUser) {
        _currentUser = currentUser;
//        if (!self.managedObjectContext) {
//            self.managedObjectContext = currentUser.managedObjectContext;
//        }
    }
}

- (NSManagedObjectContext*)managedObjectContext
{
    if (_managedObjectContext == nil) {
        AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        _managedObjectContext = delegate.managedObjectContext;
    }
    return _managedObjectContext;
}

@end
