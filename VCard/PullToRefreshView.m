//
//  PullToRefreshView.m
//  Grant Paul (chpwn)
//
//  (based on EGORefreshTableHeaderView)
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "PullToRefreshView.h"

#define TEXT_COLOR	 [UIColor colorWithRed:(87.0/255.0) green:(108.0/255.0) blue:(137.0/255.0) alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f


@interface PullToRefreshView (Private)

@property (nonatomic, assign) PullToRefreshViewState state;

@end

@implementation PullToRefreshView
@synthesize delegate, scrollView;

- (void)setImageFlipped:(BOOL)flipped {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2f];
    reloadArrowView.layer.transform = (flipped ? CATransform3DMakeRotation(- M_PI * 2, 0.0f, 0.0f, 1.0f) : CATransform3DMakeRotation(- M_PI, 0.0f, 0.0f, 1.0f));
    reloadCircleView.layer.transform = (flipped ? CATransform3DMakeRotation(- M_PI * 2, 0.0f, 0.0f, 1.0f) : CATransform3DMakeRotation(- M_PI, 0.0f, 0.0f, 1.0f));
    [UIView commitAnimations];
    
    [UIView animateWithDuration:0.2 animations:^{
        reloadArrowView.alpha = flipped ? 0.0 : 1.0;
        reloadCircleView.alpha = flipped ? 1.0 : 0.0;
    }];
}

- (id)initWithScrollView:(UIScrollView *)scroll {
    CGRect frame = CGRectMake(0.0f, 0.0f - scroll.bounds.size.height, scroll.bounds.size.width, scroll.bounds.size.height);
    
    if ((self = [super initWithFrame:frame])) {
        scrollView = scroll;
        [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
        
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor colorWithRed:80.0/255.0 green:80.0/255.0 blue:80.0/255.0 alpha:1.0];
        
        bottomImageView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 7.0f, self.frame.size.width, 8.0f)];
        bottomImageView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"reload_bg_btm.png"]];
        bottomImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:bottomImageView];
        
        topImageView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 54.0f, self.frame.size.width, 54.0f)];
        topImageView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"reload_bg_shadow_down.png"]];
        topImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:topImageView];
        
        reloadHoleView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 44.0f, self.frame.size.width, 32.0f)];
        reloadHoleView.image = [UIImage imageNamed:@"reload_hole.png"];
        reloadHoleView.contentMode = UIViewContentModeCenter;
        reloadHoleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:reloadHoleView];
        
        reloadCircleView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f, self.frame.size.width, 40.0f)];
        reloadCircleView.image = [UIImage imageNamed:@"reload_circle.png"];
        reloadCircleView.contentMode = UIViewContentModeCenter;
        reloadCircleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        reloadCircleView.alpha = 0.0;
        [self addSubview:reloadCircleView];
        
        reloadArrowView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f, self.frame.size.width, 40.0f)];
        reloadArrowView.image = [UIImage imageNamed:@"reload_arrow_down.png"];
        reloadArrowView.contentMode = UIViewContentModeCenter;
        reloadArrowView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:reloadArrowView];
        
		[self setState:PullToRefreshViewStateNormal];
    }
    
    return self;
}

#pragma mark -
#pragma mark Setters

- (void)refreshLastUpdatedDate {
    NSDate *date = [NSDate date];
    
	if ([delegate respondsToSelector:@selector(pullToRefreshViewLastUpdated:)])
		date = [delegate pullToRefreshViewLastUpdated:self];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setAMSymbol:@"AM"];
    [formatter setPMSymbol:@"PM"];
    [formatter setDateFormat:@"MM/dd/yy hh:mm a"];
}

- (void)setState:(PullToRefreshViewState)state_ {
    state = state_;
    
	switch (state) {
		case PullToRefreshViewStateReady:
            [self setImageFlipped:YES];
            scrollView.contentInset = UIEdgeInsetsZero;
			break;
            
		case PullToRefreshViewStateNormal:
            [self setImageFlipped:NO];
			[self refreshLastUpdatedDate];
            scrollView.contentInset = UIEdgeInsetsZero;
			break;
            
		case PullToRefreshViewStateLoading:
            [self setImageFlipped:YES];
            scrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
            [self startLoadingAnimation];
			break;
            
		default:
			break;
	}
}

#pragma mark -
#pragma mark UIScrollView

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        if (scrollView.isDragging) {
            if (state == PullToRefreshViewStateReady) {
                if (scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f) 
                    [self setState:PullToRefreshViewStateNormal];
            } else if (state == PullToRefreshViewStateNormal) {
                if (scrollView.contentOffset.y < -65.0f)
                    [self setState:PullToRefreshViewStateReady];
            } else if (state == PullToRefreshViewStateLoading) {
                if (scrollView.contentOffset.y >= 0)
                    scrollView.contentInset = UIEdgeInsetsZero;
                else
                    scrollView.contentInset = UIEdgeInsetsMake(MIN(-scrollView.contentOffset.y, 60.0f), 0, 0, 0);
            }
        } else {
            if (state == PullToRefreshViewStateReady) {
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.2f];
                [self setState:PullToRefreshViewStateLoading];
                [UIView commitAnimations];
                
                if ([delegate respondsToSelector:@selector(pullToRefreshViewShouldRefresh:)])
                    [delegate pullToRefreshViewShouldRefresh:self];
            }
        }
        self.frame = CGRectMake(scrollView.contentOffset.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        CGFloat topImageViewOriginY = scrollView.contentOffset.y > - 54.0f ? -54.0f : scrollView.contentOffset.y;
        
        CGRect frame = topImageView.frame;
        frame.origin = CGPointMake(scrollView.contentOffset.x, self.frame.size.height + topImageViewOriginY);
        topImageView.frame = frame;
    }
}

- (void)finishedLoading {
    if (state == PullToRefreshViewStateLoading) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3f];
        [self setState:PullToRefreshViewStateNormal];
        [UIView commitAnimations];
    }
}

- (void)startLoadingAnimation
{
    reloadCircleView.alpha = 1.0;
	reloadHoleView.alpha = 1.0;
    reloadArrowView.alpha = 0.0;
	
	CABasicAnimation *rotationAnimation =[CABasicAnimation animationWithKeyPath:@"transform.rotation"];
	rotationAnimation.duration = 1.0;
	rotationAnimation.fromValue = [NSNumber numberWithFloat:0.0];
	rotationAnimation.toValue = [NSNumber numberWithFloat:2.0 * M_PI];
	rotationAnimation.repeatCount = 65535;
	[reloadCircleView.layer addAnimation:rotationAnimation forKey:@"kAnimationLoad"];
}

- (void)stopLoadingAnimation
{
    reloadArrowView.alpha = 1.0;
    [reloadCircleView.layer removeAllAnimations];
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	[scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

@end
