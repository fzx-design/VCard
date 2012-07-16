//
//  ShelfDrawerView.h
//  VCard
//
//  Created by 海山 叶 on 12-7-5.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShelfDrawerViewDelegate <NSObject>

- (void)didClickDeleteButtonAtIndex:(int)index;

@end

@interface ShelfDrawerView : UIButton {
    UIImageView *_photoFrameImageView;
    UIImageView *_photoImageView;
    UIImageView *_backImageView;
    UIImageView *_highlightGlowImageView;
    UILabel *_topicLabel;
    UIButton *_deleteButton;
}

@property (nonatomic, strong) NSString *topicName;
@property (nonatomic, strong) NSString *picURL;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) BOOL imageLoaded;
@property (nonatomic, assign) BOOL editing;

@property (nonatomic, weak) id<ShelfDrawerViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame
          topicName:(NSString *)name
             picURL:(NSString *)url
              index:(NSInteger)index
               type:(int)type
              empty:(BOOL)empty;

- (void)loadImageFromURL:(NSString *)urlString 
              completion:(void (^)(BOOL succeeded))completion;

- (void)showDeleteButton;
- (void)hideDeleteButton;

@end
