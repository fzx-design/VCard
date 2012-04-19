//
//  CoreDataViewController.m
//  PushBox
//
//  Created by Xie Hasky on 11-7-24.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "CoreDataViewController.h"
#import "User.h"

@implementation CoreDataViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize currentUser = _currentUser;

- (void)setCurrentUser:(User *)currentUser
{
    if (_currentUser != currentUser) {
        _currentUser = currentUser;
        if (!self.managedObjectContext) {
            self.managedObjectContext = currentUser.managedObjectContext;
        }
    }
}

@end
