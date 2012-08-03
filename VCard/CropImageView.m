//
//  CropImageView.m
//  VCard
//
//  Created by 紫川 王 on 12-4-18.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "CropImageView.h"
#import <QuartzCore/QuartzCore.h>

typedef enum {
    PointPositionLeftTop,
    PointPositionRightTop,
    PointPositionRightBottom,
    PointPositionLeftBottom,
} PointPositionIdentifier;

#define MINIMUM_INTERVAL 250.0f

#define DEFAULT_CROP_SECTION_NUM 3
#define DEFAULT_ASSIST_CROP_SECTION_NUM 2
#define MAX_SCALE_FACTOR 3

@interface CropImageView() {
    UIImageView *_draggingPointImageView;
    CGPoint _formerTouchPoint;
    
    CGFloat _minimumXArray[4];
    CGFloat _minimumYArray[4];
    CGFloat _maximumXArray[4];
    CGFloat _maximumYArray[4];
    
    CGSize _cropImageInitSize;
    CGPoint _cropImageInitCenter;
    
    BOOL _lockRatio;
}

@property (nonatomic, strong) NSMutableArray *pointImageViewArray;
@property (nonatomic, assign) CGFloat dragDistanceX;
@property (nonatomic, assign) CGFloat dragDistanceY;
@property (nonatomic, assign) int cropSectionNum;
@property (nonatomic, assign) int assistCropSectionNum;

@end

@implementation CropImageView

@synthesize pointImageViewArray = _pointImageViewArray;
@synthesize bgImageView = _bgImageView;
@synthesize rotationFactor = _rotationFactor;
@synthesize scaleFactor = _scaleFactor;
@synthesize dragDistanceX = _dragDistanceX;
@synthesize dragDistanceY = _dragDistanceY;
@synthesize cropSectionNum = _cropSectionNum;
@synthesize assistCropSectionNum = _assistCropSectionNum;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        self.cropSectionNum = DEFAULT_CROP_SECTION_NUM;
        self.assistCropSectionNum = 1;
        
        self.pointImageViewArray = [[NSMutableArray alloc] initWithCapacity:4];
        for(int i = 0; i < 4; i++) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"motions_crop_puller.png"]];
            [self.pointImageViewArray addObject:imageView];
            [self addSubview:imageView];
        }
        
        self.scaleFactor = 1.0f;
        
        UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotatePiece:)];
        [self addGestureRecognizer:rotationGesture];
        
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scalePiece:)];
        [self addGestureRecognizer:pinchGesture];
    }
    return self;
}

- (void)setDefault {
    CGPoint center = _cropImageInitCenter;
    CGPoint leftTopPoint = CGPointMake(center.x - _cropImageInitSize.width / 2, center.y - _cropImageInitSize.height / 2);
    CGPoint rightBottomPoint = CGPointMake(center.x + _cropImageInitSize.width / 2, center.y + _cropImageInitSize.height / 2);
    
    CGFloat minimumXArray[] = {leftTopPoint.x, leftTopPoint.x + MINIMUM_INTERVAL, leftTopPoint.x + MINIMUM_INTERVAL, leftTopPoint.x};
    CGFloat minimumYArray[] = {leftTopPoint.y, leftTopPoint.y, leftTopPoint.y + MINIMUM_INTERVAL, leftTopPoint.y + MINIMUM_INTERVAL};
    CGFloat maximumXArray[] = {rightBottomPoint.x - MINIMUM_INTERVAL, rightBottomPoint.x, rightBottomPoint.x, rightBottomPoint.x - MINIMUM_INTERVAL};
    CGFloat maximumYArray[] = {rightBottomPoint.y - MINIMUM_INTERVAL, rightBottomPoint.y - MINIMUM_INTERVAL, rightBottomPoint.y, rightBottomPoint.y};
    
    for(int i = 0; i < 4; i++) {
        _minimumXArray[i] = minimumXArray[i];
        _minimumYArray[i] = minimumYArray[i];
        _maximumXArray[i] = maximumXArray[i];
        _maximumYArray[i] = maximumYArray[i];
    }
    
    if(_lockRatio) {
        CGFloat min = fminf(_cropImageInitSize.width / 2, _cropImageInitSize.height / 2);
        leftTopPoint = CGPointMake(center.x - min, center.y - min);
        rightBottomPoint = CGPointMake(center.x + min, center.y + min);
    }
    
    [self pointImageViewWithIdentifier:PointPositionLeftTop].center = leftTopPoint;
    [self pointImageViewWithIdentifier:PointPositionRightBottom].center = rightBottomPoint;
    [self pointImageViewWithIdentifier:PointPositionLeftBottom].center = CGPointMake(leftTopPoint.x, rightBottomPoint.y);
    [self pointImageViewWithIdentifier:PointPositionRightTop].center = CGPointMake(rightBottomPoint.x, leftTopPoint.y);
    
}

- (UIImageView *)pointImageViewWithIdentifier:(PointPositionIdentifier)identifier {
    return [self.pointImageViewArray objectAtIndex:identifier];
}

#pragma mark - Draw methods

- (void)drawShadow {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorRef colorRef = CGColorCreateCopyWithAlpha([UIColor blackColor].CGColor, 0.6f);
    CGContextSetFillColorWithColor(context, colorRef);
    CGColorRelease(colorRef);
    
    CGRect rectangle = CGRectMake(0, 0, (int)[self pointImageViewWithIdentifier:PointPositionRightTop].center.x, (int)[self pointImageViewWithIdentifier:PointPositionRightTop].center.y);
    CGContextAddRect(context, rectangle);
    CGContextFillRect(context, rectangle);
    
    rectangle = CGRectMake((int)[self pointImageViewWithIdentifier:PointPositionRightTop].center.x, 0, self.frame.size.width - (int)[self pointImageViewWithIdentifier:PointPositionRightBottom].center.x, (int)[self pointImageViewWithIdentifier:PointPositionRightBottom].center.y);
    CGContextAddRect(context, rectangle);
    CGContextFillRect(context, rectangle);
    
    rectangle = CGRectMake((int)[self pointImageViewWithIdentifier:PointPositionLeftBottom].center.x, (int)[self pointImageViewWithIdentifier:PointPositionLeftBottom].center.y, self.frame.size.width, self.frame.size.height);
    CGContextAddRect(context, rectangle);
    CGContextFillRect(context, rectangle);
    
    rectangle = CGRectMake(0, (int)[self pointImageViewWithIdentifier:PointPositionLeftTop].center.y, (int)[self pointImageViewWithIdentifier:PointPositionLeftTop].center.x, self.frame.size.height - (int)[self pointImageViewWithIdentifier:PointPositionLeftTop].center.y);
    CGContextAddRect(context, rectangle);
    CGContextFillRect(context, rectangle);
}

- (void)drawLine {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);
    CGColorRef colorRef = CGColorCreateCopyWithAlpha([UIColor whiteColor].CGColor, 0.6f);
    CGContextSetStrokeColorWithColor(context, colorRef);
    CGColorRelease(colorRef);
    
    CGPoint initPos = [self pointImageViewWithIdentifier:PointPositionLeftBottom].center;
    CGContextMoveToPoint(context, initPos.x, initPos.y);
    for(UIImageView *pointImageView in self.pointImageViewArray) {
        CGPoint currentPos = pointImageView.center;
        CGContextAddLineToPoint(context, currentPos.x, currentPos.y);
        CGContextMoveToPoint(context, currentPos.x, currentPos.y);
    }
    CGContextStrokePath(context);
    
    CGContextSetLineWidth(context, 1.0);
    CGPoint leftTopPoint = [self pointImageViewWithIdentifier:PointPositionLeftTop].center;
    CGPoint rightBottom = [self pointImageViewWithIdentifier:PointPositionRightBottom].center;
    CGSize cropSize = CGSizeMake(rightBottom.x - leftTopPoint.x , rightBottom.y - leftTopPoint.y);
    CGSize cropSectionSize = CGSizeMake(cropSize.width / self.cropSectionNum, cropSize.height / self.cropSectionNum);
        
    for(int i = 1; i < self.cropSectionNum; i++) {
        CGPoint verticalPos = CGPointMake(leftTopPoint.x + i * cropSectionSize.width, leftTopPoint.y);
        CGContextMoveToPoint(context, verticalPos.x, verticalPos.y);
        CGContextAddLineToPoint(context, verticalPos.x, verticalPos.y + cropSize.height);
        CGContextStrokePath(context);
        
        CGPoint horizontalPos = CGPointMake(leftTopPoint.x, leftTopPoint.y + i * cropSectionSize.height);
        CGContextMoveToPoint(context, horizontalPos.x, horizontalPos.y);
        CGContextAddLineToPoint(context, horizontalPos.x + cropSize.width, horizontalPos.y);
        CGContextStrokePath(context);
    }
    
    CGContextSetLineWidth(context, 0.5);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:1 green:198.0f / 255.0f blue:15.0f / 255.0f alpha:0.6f].CGColor);
    //float dash[2] = {6, 6};
    //CGContextSetLineDash(context, 0, dash, 2);
    for(int i = 0; i < (self.assistCropSectionNum - 1) * self.cropSectionNum; i++) {
        CGPoint verticalPos = CGPointMake(leftTopPoint.x + i / (self.assistCropSectionNum - 1) * cropSectionSize.width + (i % (self.assistCropSectionNum - 1) + 1) * cropSectionSize.width / self.assistCropSectionNum, leftTopPoint.y);
        CGContextMoveToPoint(context, verticalPos.x, verticalPos.y);
        CGContextAddLineToPoint(context, verticalPos.x, verticalPos.y + cropSize.height);
        CGContextStrokePath(context);
        
        CGPoint horizontalPos = CGPointMake(leftTopPoint.x, leftTopPoint.y + i / (self.assistCropSectionNum - 1) * cropSectionSize.height + (i % (self.assistCropSectionNum - 1) + 1) * cropSectionSize.height / self.assistCropSectionNum);
        CGContextMoveToPoint(context, horizontalPos.x, horizontalPos.y);
        CGContextAddLineToPoint(context, horizontalPos.x + cropSize.width, horizontalPos.y);
        CGContextStrokePath(context);
    }
    
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self drawShadow];
    [self drawLine];
}

#pragma mark - Logic methods

- (CGPoint)movePullerWithDistanceX:(CGFloat)distanceX distanceY:(CGFloat)distanceY touchPoint:(CGPoint)point {
    
    CGPoint result = point;
    
    if(_lockRatio) {
        CGFloat distance = fabsf(distanceX) > fabsf(distanceY) ? fabsf(distanceX) : fabsf(distanceY);
        distanceX = distanceY > 0 ? distance : distance * -1;
        distanceY = distanceX;
        PointPositionIdentifier pointIdentifier = [self.pointImageViewArray indexOfObject:_draggingPointImageView];
        if(pointIdentifier % 2 == 1)
            distanceX *= -1;
    }
    
    CGPoint preservedPoint[4];
    for(int i = 0; i < 4; i++) {
        preservedPoint[i] = [self pointImageViewWithIdentifier:i].center;
    }
        
    CGPoint center = _draggingPointImageView.center;
    center.x += distanceX;
    center.y += distanceY;
    _draggingPointImageView.center = center;
    
    PointPositionIdentifier pointIdentifier = [self.pointImageViewArray indexOfObject:_draggingPointImageView];
    PointPositionIdentifier oppositePointIdentifier = (pointIdentifier + 2) % 4;
    UIImageView *oppositePointImageView = [self.pointImageViewArray objectAtIndex:oppositePointIdentifier];
    
    BOOL dragingPointXInvalid = (oppositePointImageView.center.x - _draggingPointImageView.center.x) * (oppositePointIdentifier % 3 ? 1 : -1) < MINIMUM_INTERVAL;
    BOOL dragingPointYInvalid = (oppositePointImageView.center.y - _draggingPointImageView.center.y) * (oppositePointIdentifier > 1 ? 1 : -1) < MINIMUM_INTERVAL;
    
    CGFloat x = - _cropImageInitSize.width / 2 * self.scaleFactor;
    CGFloat y = - _cropImageInitSize.height / 2 * self.scaleFactor;
    CGFloat w = _cropImageInitSize.width * self.scaleFactor;
    CGFloat h = _cropImageInitSize.height * self.scaleFactor;
    CGPoint leftTop = [self pointImageViewWithIdentifier:PointPositionLeftTop].center;
    CGPoint rightBottom = [self pointImageViewWithIdentifier:PointPositionRightBottom].center;
    
    CGRect bound = CGRectMake(x, y, w, h);
    bound = [CropImageView getRotatedImageBound:bound withRotation:self.rotationFactor];
    bound.origin.x += self.bgImageView.center.x;
    bound.origin.y += self.bgImageView.center.y;
    
    if(leftTop.x < bound.origin.x || rightBottom.x > bound.origin.x + bound.size.width)
        dragingPointXInvalid = YES;
    if(leftTop.y < bound.origin.y || rightBottom.y > bound.origin.y + bound.size.height)
        dragingPointYInvalid = YES;
    
    if(_lockRatio) {
        __block BOOL outOfBounds = NO;
        [self.pointImageViewArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIImageView *pointImageView = obj;
            if(pointImageView.center.x < _minimumXArray[idx])
                outOfBounds = YES;
            if(pointImageView.center.x > _maximumXArray[idx])
                outOfBounds = YES;
            if(pointImageView.center.y < _minimumYArray[idx])
                outOfBounds = YES;
            if(pointImageView.center.y > _maximumYArray[idx])
                outOfBounds = YES;
        }];
        
        if(dragingPointXInvalid || dragingPointYInvalid || outOfBounds) {
            dragingPointXInvalid = YES;
            dragingPointYInvalid = YES;
        }
    }
    
    if(dragingPointXInvalid) {
        center.x -= distanceX;
        _draggingPointImageView.center = center;
        result.x = _formerTouchPoint.x;
    }
    if(dragingPointYInvalid) {
        center.y -= distanceY;
        _draggingPointImageView.center = center;
        result.y = _formerTouchPoint.y;
    }
    
    UIImageView *pointWithSameX = [self pointImageViewWithIdentifier:(pointIdentifier + 1) % 4];
    UIImageView *pointWithSameY = [self pointImageViewWithIdentifier:(pointIdentifier + 3) % 4];
    if(pointIdentifier % 2 == 0) {
        UIImageView *temp = pointWithSameX;
        pointWithSameX = pointWithSameY;
        pointWithSameY = temp;
    }
    pointWithSameX.center = CGPointMake(_draggingPointImageView.center.x, pointWithSameX.center.y);
    pointWithSameY.center = CGPointMake(pointWithSameY.center.x, _draggingPointImageView.center.y);
    
    [self.pointImageViewArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIImageView *pointImageView = obj;
        if(pointImageView.center.x < _minimumXArray[idx])
            pointImageView.center = CGPointMake(_minimumXArray[idx], pointImageView.center.y);
        if(pointImageView.center.x > _maximumXArray[idx])
            pointImageView.center = CGPointMake(_maximumXArray[idx], pointImageView.center.y);
        if(pointImageView.center.y < _minimumYArray[idx])
            pointImageView.center = CGPointMake(pointImageView.center.x, _minimumYArray[idx]);
        if(pointImageView.center.y > _maximumYArray[idx])
            pointImageView.center = CGPointMake(pointImageView.center.x, _maximumYArray[idx]);
    }];
    
    if(![self isRotateValid:self.rotationFactor]) {
        for(int i = 0; i < 4; i++) {
            [self pointImageViewWithIdentifier:i].center = preservedPoint[i];
        }
    }
    
    return result;
}

- (void)moveBgImageViewWithDistanceX:(CGFloat)distanceX distanceY:(CGFloat)distanceY {
    CGPoint center = self.bgImageView.center;
    center.y += distanceY;
    center.x += distanceX;
    CGFloat x = - _cropImageInitSize.width / 2 * self.scaleFactor;
    CGFloat y = - _cropImageInitSize.height / 2 * self.scaleFactor;
    CGFloat w = _cropImageInitSize.width * self.scaleFactor;
    CGFloat h = _cropImageInitSize.height * self.scaleFactor;
    CGPoint leftTop = [self pointImageViewWithIdentifier:PointPositionLeftTop].center;
    CGPoint rightBottom = [self pointImageViewWithIdentifier:PointPositionRightBottom].center;
    
    CGRect bound = CGRectMake(x, y, w, h);
    bound = [CropImageView getRotatedImageBound:bound withRotation:self.rotationFactor];
    bound.origin.x += center.x;
    bound.origin.y += center.y;
    
    self.dragDistanceX += distanceX;
    if(leftTop.x < bound.origin.x || rightBottom.x > bound.origin.x + bound.size.width || ![self isRotateValid:self.rotationFactor]) {
        center.x -= distanceX;
        self.dragDistanceX -= distanceX;
    }
    
    self.dragDistanceY += distanceY;
    if(leftTop.y < bound.origin.y || rightBottom.y > bound.origin.y + bound.size.height || ![self isRotateValid:self.rotationFactor]) {
        center.y -= distanceY;
        self.dragDistanceY -= distanceY;
    }
    
    self.bgImageView.center = center;
}

#pragma mark - Touch handler

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    for(UIImageView *pointImageView in self.pointImageViewArray) {
        CGPoint center = pointImageView.center;
        CGRect frame = CGRectMake(center.x - 22, center.y - 22, 44, 44);
        if(CGRectContainsPoint(frame, point)) {
            _draggingPointImageView = pointImageView;
            break;
        }
    }
    _formerTouchPoint = point;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGFloat distanceX = point.x - _formerTouchPoint.x;
    CGFloat distanceY = point.y - _formerTouchPoint.y;
    if(_draggingPointImageView) {
        point = [self movePullerWithDistanceX:distanceX distanceY:distanceY touchPoint:point];
    }
    else {
        [self moveBgImageViewWithDistanceX:distanceX distanceY:distanceY];
    }
    
    _formerTouchPoint = point;
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    _draggingPointImageView = nil;
}

- (void)setCropImageInitSize:(CGSize)size center:(CGPoint)center lockRatio:(BOOL)lockRatio {
    _cropImageInitSize = size;
    _cropImageInitCenter = center;
    _lockRatio = lockRatio;
    [self setDefault];
}

- (CGRect)cropImageRect {
    CGPoint leftTop = [self pointImageViewWithIdentifier:PointPositionLeftTop].center;
    CGPoint rightBottom = [self pointImageViewWithIdentifier:PointPositionRightBottom].center;
    CGSize size = CGSizeMake(rightBottom.x - leftTop.x, rightBottom.y - leftTop.y);
    CGPoint origin = CGPointMake(leftTop.x - _minimumXArray[PointPositionLeftTop] - self.dragDistanceX, leftTop.y - _minimumYArray[PointPositionLeftTop] - self.dragDistanceY);
    CGRect cropImageRect = CGRectMake(origin.x, origin.y, size.width, size.height);
        
    CGFloat factor = 1 / self.bgImageView.contentScaleFactor;
    cropImageRect = CGRectMake(cropImageRect.origin.x * factor, cropImageRect.origin.y * factor, cropImageRect.size.width * factor, cropImageRect.size.height * factor);
    
    CGFloat x = cropImageRect.origin.x;
    CGFloat y = cropImageRect.origin.y;
    CGFloat w = cropImageRect.size.width;
    CGFloat h = cropImageRect.size.height;
    CGPoint center = CGPointMake(self.bgImageView.image.size.width / 2, self.bgImageView.image.size.height / 2);
    
    CGRect scaleFrame = CGRectMake(center.x  - (center.x - x) / self.scaleFactor, center.y - (center.y - y) / self.scaleFactor, w / self.scaleFactor, h / self.scaleFactor);
    
    return scaleFrame;
}

- (CGRect)cropEditRect {
    CGPoint leftTop = [self pointImageViewWithIdentifier:PointPositionLeftTop].center;
    CGPoint rightBottom = [self pointImageViewWithIdentifier:PointPositionRightBottom].center;
    CGSize size = CGSizeMake(rightBottom.x - leftTop.x, rightBottom.y - leftTop.y);
    CGPoint origin = CGPointMake(leftTop.x, leftTop.y);
    CGRect rect = CGRectMake(origin.x, origin.y, size.width, size.height);
    return rect;
}

#pragma mark -
#pragma mark Pinch & Rotate methods 

- (BOOL)isRotateValid:(CGFloat)rotation {
    CGRect rect1 = CGRectMake(0, 0, self.bgImageView.image.size.width, self.bgImageView.image.size.height);
    CGRect rect2 = self.cropImageRect;
    rect2.origin = CGPointMake(rect2.origin.x - rect1.size.width / 2, rect2.origin.y - rect1.size.height / 2);
    if(![CropImageView isRetangle:rect1 withRotation:rotation containRectanle:rect2])
        return NO;
    return YES;
}

- (BOOL)isScaleValid:(CGFloat)scale {
    if(scale > MAX_SCALE_FACTOR)
        return NO;
    if(![self isRotateValid:self.rotationFactor] && self.rotationFactor != 0)
        return NO;
    return YES;
}

- (void)varifyScale {
    CGPoint center = self.bgImageView.center;
    CGFloat x = center.x - _cropImageInitSize.width / 2 * self.scaleFactor;
    CGFloat y = center.y - _cropImageInitSize.height / 2 * self.scaleFactor;
    CGFloat w = _cropImageInitSize.width * self.scaleFactor;
    CGFloat h = _cropImageInitSize.height * self.scaleFactor;
    CGPoint leftTop = [self pointImageViewWithIdentifier:PointPositionLeftTop].center;
    CGPoint rightBottom = [self pointImageViewWithIdentifier:PointPositionRightBottom].center;
    
    if(leftTop.x < x || rightBottom.x > x + w) {
        CGFloat offset = 0;
        if(leftTop.x < x) {
            offset = leftTop.x - x;
        }
        else {
            offset = rightBottom.x - x - w;
        }
        center.x += offset;
        self.dragDistanceX += offset;
    }
    if(leftTop.y < y || rightBottom.y > y + h) {
        CGFloat offset = 0;
        if(leftTop.y < y) {
            offset = leftTop.y - y;
        }
        else {
            offset = rightBottom.y - y - h;
        }
        center.y += offset;
        self.dragDistanceY += offset;
    }
    self.bgImageView.center = center;
}

- (void)rotatePiece:(UIRotationGestureRecognizer *)gestureRecognizer {    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        self.assistCropSectionNum = DEFAULT_ASSIST_CROP_SECTION_NUM;
        if([self isRotateValid:self.rotationFactor + gestureRecognizer.rotation]) {
            self.bgImageView.transform = CGAffineTransformRotate(self.bgImageView.transform, gestureRecognizer.rotation);
            self.rotationFactor += gestureRecognizer.rotation;
        }
        [gestureRecognizer setRotation:0];
    }
    else if([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        self.assistCropSectionNum = 1;
    }
    [self setNeedsDisplay];
}

- (void)scalePiece:(UIPinchGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {        
        if(self.scaleFactor * gestureRecognizer.scale < 1)
            gestureRecognizer.scale = 1 / self.scaleFactor;
        self.scaleFactor *= gestureRecognizer.scale;
        if([self isScaleValid:self.scaleFactor]) {
            self.bgImageView.transform = CGAffineTransformScale(self.bgImageView.transform, gestureRecognizer.scale, gestureRecognizer.scale);
            [self varifyScale];
        }
        else {
            self.scaleFactor /= gestureRecognizer.scale;
        }
        [gestureRecognizer setScale:1];
    }
}

#pragma mark -
#pragma mark Rotated rectangle contain detection

typedef struct {
    float x, y;
} Vector;

Vector makeVector(float x, float y) {
    Vector result;
    result.x = x;
    result.y = y;
    return result;
}

float mulVectorWithVector(Vector vec1, Vector vec2) {
    return vec1.x * vec2.x + vec1.y * vec2.y;
}

Vector mulVectorWithNumber(Vector vec, float num) {
    return makeVector(vec.x * num, vec.y * num);
}

float projVectorToAxis(Vector src, Vector axis) {
    float axisVecLength = sqrtf(axis.x * axis.x + axis.y * axis.y);
    return (src.x * axis.x + src.y * axis.y) / axisVecLength;
}

Vector projVectorToAxises(Vector src, Vector axisX, Vector axisY) {
    return makeVector(projVectorToAxis(src, axisX), projVectorToAxis(src, axisY));
}

Vector rotateVector(Vector src, float rotate) {
    //x*cos(d)-y*sin(d) , x*sin(d)+y*cos(d) 
    return makeVector(src.x * cosf(rotate) - src.y * sinf(rotate), src.x * sinf(rotate) + src.y * cosf(rotate));
}

+ (BOOL)isRetangle:(CGRect)rect1 withRotation:(CGFloat)rotateFactor containRectanle:(CGRect)rect2 {
    if(rotateFactor == 0)
        return YES;
    Vector axisX = makeVector(cosf(rotateFactor), sinf(rotateFactor));
    Vector axisY = makeVector(-sinf(rotateFactor), cosf(rotateFactor));
    
    float rect1MinX = -rect1.size.width / 2;
    float rect1MaxX = rect1.size.width / 2;
    float rect1MinY = -rect1.size.height / 2;
    float rect1MaxY = rect1.size.height / 2;
    
    
    Vector rect2LT = makeVector(rect2.origin.x, rect2.origin.y);
    Vector rect2LB = makeVector(rect2.origin.x, rect2.origin.y + rect2.size.height);
    Vector rect2RT = makeVector(rect2.origin.x + rect2.size.width, rect2.origin.y);
    Vector rect2RB = makeVector(rect2.origin.x + rect2.size.width, rect2.origin.y + rect2.size.height);
        
    Vector rect2Points[4] = {rect2LT, rect2LB, rect2RT, rect2RB};
    
    for(int i = 0; i < 4; i++) {
        rect2Points[i] = projVectorToAxises(rect2Points[i], axisX, axisY);
        if(rect2Points[i].x < rect1MinX || rect2Points[i].x > rect1MaxX
           || rect2Points[i].y < rect1MinY || rect2Points[i].y > rect1MaxY) {
            return NO;
        }
    }
    return YES;
}

+ (CGRect)getRotatedImageBound:(CGRect)rect withRotation:(CGFloat)rotateFactor {
    if(rotateFactor == 0)
        return rect;
    Vector rectLT = makeVector(rect.origin.x, rect.origin.y);
    Vector rectLB = makeVector(rect.origin.x, rect.origin.y + rect.size.height);
    Vector rectRT = makeVector(rect.origin.x + rect.size.width, rect.origin.y);
    Vector rectRB = makeVector(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    
    float minX = rectLT.x, minY = rectLT.y, maxX = rectLT.x, maxY = rectLT.y;

    Vector rectPoints[4] = {rectLT, rectLB, rectRT, rectRB};
    
    for(int i = 0; i < 4; i++) {
        Vector p = rotateVector(rectPoints[i], rotateFactor);
        minX = minX < p.x ? minX : p.x;
        minY = minY < p.y ? minY : p.y;
        maxX = maxX > p.x ? maxX : p.x;
        maxY = maxY > p.y ? maxY : p.y;
    }
    CGRect result = CGRectMake(minX, minY, maxX - minX, maxY - minY);
    return result;
}

@end
