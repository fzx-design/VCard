//
//  CardImageView.h
//  VCard
//
//  Created by 海山 叶 on 12-4-14.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardImageViewShadowView.h"

@interface CardImageView : UIImageView {
    CardImageViewShadowView *_shadowView;
}

@end
