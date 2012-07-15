//
//  SearchTableViewController.h
//  VCard
//
//  Created by 海山 叶 on 12-7-4.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SearchTableViewStateNormal,
    SearchTableviewStateTyping,
    SearchTableViewStateSearching,
} SearchTableViewState;

typedef enum {
    SearchingTargetTypeStatus,
    SearchingTargetTypeUser,
} SearchingTargetType;

@protocol SearchTableViewControllerDelegate <NSObject>

- (void)didSelectCell;

@end

@interface SearchTableViewController : UITableViewController <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) NSInteger                 pageIndex;
@property (nonatomic, strong) NSMutableArray            *hotTopics;
@property (nonatomic, strong) NSMutableArray            *searchUserHistoryList;
@property (nonatomic, strong) NSMutableArray            *searchStatusHistoryList;

@property (nonatomic, strong) NSMutableArray            *searchNameSuggestions;
@property (nonatomic, strong) NSMutableArray            *searchStatusSuggestions;

@property (nonatomic, strong) NSString                  *searchKey;
@property (nonatomic, readonly) SearchTableViewState    tableViewState;
@property (nonatomic, readonly) SearchingTargetType     searchingType;

@property (nonatomic, weak) id<SearchTableViewControllerDelegate> delegate;

- (void)setState:(SearchTableViewState)state;
- (void)setSearchingType:(SearchingTargetType)searchingType;
- (void)updateSuggestionWithKey:(NSString *)key;
- (void)search;

@end
