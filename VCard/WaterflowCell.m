//
//  WaterflowCell.m
//  VCard
//
//  Created by 海山 叶 on 12-4-19.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "WaterflowCell.h"

@implementation WaterflowCell

@synthesize indexPath = _indexPath;
@synthesize reuseIdentifier = _reuseIdentifier;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier currentUser:(User*)currentUser_
{
    if(self = [super init])
	{
		self.reuseIdentifier = reuseIdentifier;
    }
	
	return self;
}

- (void)loadImageAfterScrollingStop
{
    
}

- (void)prepareForReuse
{
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

}

- (void)setCellHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (void)resetLayoutAfterRotating
{
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
