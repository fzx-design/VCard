//
//  ShelfDrawerView.h
//  VCard
//
//  Created by 海山 叶 on 12-7-5.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShelfDrawerView : UIView {
    UIImageView *_photoFrameImageView;
    UIImageView *_imageView;
    UIImageView *_backImageView;
    UILabel *_topicLabel;
}

@property (nonatomic, strong) NSString *topicName;
@property (nonatomic, strong) NSString *picURL;
@property (nonatomic, assign) NSInteger index;

- (id)initWithFrame:(CGRect)frame
          topicName:(NSString *)name
             picURL:(NSString *)url
              index:(NSInteger)index;

- (void)loadImageFromURL:(NSString *)urlString 
              completion:(void (^)())completion;

@end
