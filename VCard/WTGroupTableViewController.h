//
//  WTGroupTableViewController.h
//  WeTongji
//
//  Created by 紫川 王 on 12-4-14.
//  Copyright (c) 2012年 Tongji Apple Club. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataViewController.h"

@interface WTGroupTableViewController : CoreDataViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSourceIndexArray;
@property (nonatomic, strong) NSMutableDictionary *dataSourceDictionary;

//methods to overwrite
- (NSString *)customCellClassName;
- (void)configureDataSource;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
