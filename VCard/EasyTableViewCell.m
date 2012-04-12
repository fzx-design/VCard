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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    NSLog(@"CardTableViewCell awakeFromNib");
    self.transform = CGAffineTransformRotate(self.transform, M_PI_2);

    if (!_userSelectionCellViewController) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard.storyboard" bundle:nil];
        
//        _userSelectionCellViewController = [[UserSelectionCellViewController alloc] init];
        _userSelectionCellViewController = [storyboard instantiateViewControllerWithIdentifier:@"UserSelectionCellViewController"];
        _userSelectionCellViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _userSelectionCellViewController.view.tag = CELL_CONTENT_TAG;
    }
    
    [self.contentView addSubview:_userSelectionCellViewController.view];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
