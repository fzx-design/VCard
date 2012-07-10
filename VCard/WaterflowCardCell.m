//
//  WaterflowCardCell.m
//  VCard
//
//  Created by 海山 叶 on 12-5-22.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "WaterflowCardCell.h"

@implementation WaterflowCardCell

@synthesize cardViewController = _cardViewController;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier currentUser:(User*)currentUser_
{
    if(self = [super initWithReuseIdentifier:reuseIdentifier currentUser:currentUser_])
	{
		self.reuseIdentifier = reuseIdentifier;
        self.autoresizingMask = UIViewAutoresizingNone;
    }
	
	return self;
}

- (CardViewController*)cardViewController
{
    if (_cardViewController == nil) {
        _cardViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:NULL] instantiateViewControllerWithIdentifier:@"CardViewController"];
        
        CGRect frame = _cardViewController.view.frame;
        frame.origin = CGPointMake(0, 0);
        frame.size = CGSizeMake(362, 500);
        _cardViewController.view.frame = frame;
        
        [self addSubview:_cardViewController.view];
    }
    return _cardViewController;
}

- (void)loadImageAfterScrollingStop
{
    [self.cardViewController loadImage];
}

- (void)prepareForReuse
{
    [self.cardViewController prepareForReuse];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CellSelected"
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:self.indexPath forKey:@"IndexPath"]];
}

- (void)setCellHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
    
    frame = self.cardViewController.view.frame;
    frame.size.height = height;
    self.cardViewController.view.frame = frame;
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
