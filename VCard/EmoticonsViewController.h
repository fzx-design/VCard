//
//  EmoticonsViewController.h
//  VCard
//
//  Created by 紫川 王 on 12-6-6.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EmoticonsViewControllerDelegate;
@interface EmoticonsViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) id<EmoticonsViewControllerDelegate> delegate;
- (IBAction)didChangePageControlValue:(UIPageControl *)sender;

@end

@protocol EmoticonsViewControllerDelegate <NSObject>

- (void)didClickEmoticonsButtonWithInfoKey:(NSString *)key;

@end

@interface EmoticonsButton : UIButton

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSString *infoKeyName;

@end
