//
//  BaseNavigationView.h
//  VCard
//
//  Created by 海山 叶 on 12-4-18.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseNavigationView : UIView {
    UIImageView *_topBar;
    UIImageView *_topBarShadow;
    UIImageView *_infoBarView;
    UIButton *_returnButton;
    UILabel *_titleLabel;
}

- (void)showInfoBarWithTitleName:(NSString *)name;
- (void)hideInfoBar;

@end
