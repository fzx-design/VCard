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

@synthesize cardViewController = _cardViewController;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier currentUser:(User*)currentUser_
{
    if(self = [super init])
	{
		self.reuseIdentifier = reuseIdentifier;
        self.cardViewController.currentUser = currentUser_;
	}
	
	return self;
}

- (CardViewController*)cardViewController
{
    if (_cardViewController == nil) {
        _cardViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:NULL] instantiateViewControllerWithIdentifier:@"CardViewController"];
        
        CGRect frame = self.frame;
        frame.origin.x = (self.frame.size.width - frame.size.width) / 2;
        
        [self addSubview:_cardViewController.view];
    }
    return _cardViewController;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CellSelected"
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:self.indexPath forKey:@"IndexPath"]];
    
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
