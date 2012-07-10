//
//  EasyTableViewCell.m
//  VCard
//
//  Created by 海山 叶 on 12-4-12.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "EasyTableViewCell.h"
#import "EasyTableView.h"

@implementation EasyTableViewCell

@synthesize userSelectionCellViewController = _userSelectionCellViewController;

- (id)initWithStyle:(UITableViewCellStyle)style 
    reuseIdentifier:(NSString *)reuseIdentifier
         storyBoard:(UIStoryboard*)storyBoard
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setUp:storyBoard];
    }
    return self;
}

- (void)setUp:(UIStoryboard*)storyboard
{
    if (!_userSelectionCellViewController) {
                
        _userSelectionCellViewController = [[UserSelectionCellViewController alloc] init];
//        _userSelectionCellViewController.view.autoresizingMask = UIViewAutoresizingNone ;
        _userSelectionCellViewController.view.tag = CELL_CONTENT_TAG;

    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
