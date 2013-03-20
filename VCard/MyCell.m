//
//  MyCell.m
//  VCard
//
//  Created by Emerson on 13-3-19.
//  Copyright (c) 2013年 Mondev. All rights reserved.
//

#import "MyCell.h"

@implementation MyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setName:(NSString *)name{
    if(![name isEqualToString:_name]){
        _name = [name copy];
        _nameLabel.text = _name;
    }
}

-(void)setColor:(NSString *)color{
    if(![color isEqualToString:_color]){
        _color = [color copy];
        _colorLabel.text = _color;
    }
}
@end
