//
//  PostHintView.h
//  VCard
//
//  Created by 紫川 王 on 12-5-28.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PostHintViewDelegate;

@interface PostHintView : UIView <UITableViewDelegate, UITableViewDataSource> {
    NSString *_currentHintString;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *tableViewDataSourceArray;
@property (nonatomic, weak) id<PostHintViewDelegate> delegate;
@property (nonatomic, readonly) NSString *firstHintResult;
@property (nonatomic, assign) CGFloat maxViewHeight;

- (id)initWithCursorPos:(CGPoint)cursorPos;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)updateHint:(NSString *)hint;
- (void)refreshData;
- (NSString *)customCellClassName;

@end

@protocol PostHintViewDelegate <NSObject>

- (void)postHintView:(PostHintView *)hintView didSelectHintString:(NSString *)text;

@end
