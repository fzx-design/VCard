//
//  PostAtHintView.m
//  VCard
//
//  Created by 紫川 王 on 12-5-28.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "PostAtHintView.h"
#import "WBClient.h"
#import "PostAtHintCell.h"

@interface PostAtHintView()

@end

@implementation PostAtHintView

#pragma mark - methods to overwrite 

- (void)updateHint:(NSString *)hint {
    NSLog(@"at hint:%@", hint);
    _currentHintString = hint;
    if(hint.length == 0) {
        [self.tableViewDataSourceArray removeAllObjects];
        [self refreshData];
        return;
    }
    WBClient *client = [WBClient client];
    [client setCompletionBlock:^(WBClient *client) {
        if(!client.hasError) {
            if (![client.responseJSONObject isKindOfClass:[NSArray class]])
                return;
            [self.tableViewDataSourceArray removeAllObjects];
            NSArray *array = client.responseJSONObject;
            for(NSDictionary *dict in array) {
                NSString *string = [NSString stringWithFormat:@"%@", [dict objectForKey:@"nickname"]];
                [self.tableViewDataSourceArray addObject:string];
            }
            [self refreshData];
        }
    }];
    [client getAtUsersSuggestions:hint];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    PostAtHintCell *hintCell = (PostAtHintCell *)cell;
    if(self.tableViewDataSourceArray.count == 0) {
        if(_currentHintString.length == 0)
            hintCell.hintTextLabel.text = @"输入昵称或备注姓名来查找";
        else 
            hintCell.hintTextLabel.text = @"未找到相关联系人";
        hintCell.hintTextLabel.textColor = hintCell.defaultHintTextColor;
    } else {
        hintCell.hintTextLabel.text = [self.tableViewDataSourceArray objectAtIndex:indexPath.row];
        hintCell.hintTextLabel.textColor = [UIColor darkTextColor];
    }
}

- (NSString *)customCellClassName {
    if(self.tableViewDataSourceArray.count == 0)
        return @"PostTopicHintCell";
    //return @"PostAtHintCell";
    return @"PostTopicHintCell";
}

@end
