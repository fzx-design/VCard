//
//  EasyTableViewCell.h
//  VCard
//
//  Created by 海山 叶 on 12-4-12.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserSelectionCellViewController.h"

@interface EasyTableViewCell : UITableViewCell {
    UserSelectionCellViewController *_userSelectionCellViewController;
}

@property (nonatomic, strong) UserSelectionCellViewController *userSelectionCellViewController;

- (id)initWithStyle:(UITableViewCellStyle)style 
    reuseIdentifier:(NSString *)reuseIdentifier 
         storyBoard:(UIStoryboard*)storyBoard;

@end
