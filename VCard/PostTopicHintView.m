//
//  PostTopicHintView.m
//  VCard
//
//  Created by 紫川 王 on 12-6-1.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "PostTopicHintView.h"
#import "PostTopicHintCell.h"
#import "WBClient.h"

@implementation PostTopicHintView

#pragma mark - methods to overwrite 

- (void)updateHint:(NSString *)hint {
    NSLog(@"topic hint:%@", hint);
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
                NSString *string = [NSString stringWithFormat:@"%@", [dict objectForKey:@"suggestion"]];
                [self.tableViewDataSourceArray addObject:string];
            }
            [self refreshData];
        }
    }];
    [client getTopicSuggestions:hint];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    PostTopicHintCell *hintCell = (PostTopicHintCell *)cell;
    if(self.tableViewDataSourceArray.count == 0) {
        if(_currentHintString.length == 0)
            hintCell.hintTextLabel.text = @"输入话题关键词来查找";
        else 
            hintCell.hintTextLabel.text = @"未找到相关话题";
        hintCell.hintTextLabel.textColor = hintCell.defaultHintTextColor;
    } else {
        hintCell.hintTextLabel.text = [self.tableViewDataSourceArray objectAtIndex:indexPath.row];
        hintCell.hintTextLabel.textColor = [UIColor darkTextColor];
    }
}

- (NSString *)customCellClassName {
    return @"PostTopicHintCell";
}

@end
