//
//  DALCircularMenu.m
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-30.
//  Copyright (c) 2012 Reactive Development. All rights reserved.
//

#import "DALCircularMenu.h"
#import "DALCircularMenuLayoutData.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat const DALCircularMenuDefaultStretchRatio = 1.2f;
static CGFloat const DALCircularMenuDefaultCompressionRatio = 0.9f;
static CGFloat const DALCircularMenuDefaultAnimationTimeOffset = 0.03f;
static CGFloat const DALCircularMenuDefaultAnimationDuration = 0.4f;
static CGFloat const DALCircularMenuDefaultDestinationRadius = 100.f;
static CGFloat const DALCircularMenuDefaultMenuAngle = M_PI;
static CGFloat const DALCircularMenuDefaultItemRotationAngle = 0.f;
static NSString* const DALCircularMenuDefaultAnimationKey = @"animatePosition";
static NSString* const DALCircularMenuLastAnimationKey = @"lastAnimation";

static CGPoint DALRotatePointAroundCenter(CGPoint point, CGPoint center, CGFloat angle) {
    CGAffineTransform translate = CGAffineTransformMakeTranslation(center.x, center.y);
    CGAffineTransform rotate = CGAffineTransformMakeRotation(angle);
    CGAffineTransform invertedTranslation = CGAffineTransformInvert(translate);
    CGAffineTransform translateAndRotate = CGAffineTransformConcat(invertedTranslation, rotate);
    CGAffineTransform group = CGAffineTransformConcat(translateAndRotate, translate);
    return CGPointApplyAffineTransform(point, group);
}

@interface DALCircularMenu ()
@property (nonatomic, readwrite, assign) BOOL animating;
@end

@implementation DALCircularMenu {
    NSArray *_layoutData;
    NSUInteger _currentAnimationIndex;
    NSTimer *_animationTimer;
    DALCircularMenuCompletionBlock _completionBlock;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.animationOrigin = CGPointZero;
        self.stretchRatio = DALCircularMenuDefaultStretchRatio;
        self.compressionRatio = DALCircularMenuDefaultCompressionRatio;
        self.animationTimeOffset = DALCircularMenuDefaultAnimationTimeOffset;
        self.animationDuration = DALCircularMenuDefaultAnimationDuration;
        self.destinationRadius = DALCircularMenuDefaultDestinationRadius;
        self.menuAngle = DALCircularMenuDefaultMenuAngle;
        self.itemRotationAngle = DALCircularMenuDefaultItemRotationAngle;
    }
    return self;
}

#pragma mark - Accessors

- (void)setMenuItems:(NSArray *)menuItems
{
    if (_menuItems != menuItems) {
        [_menuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj removeFromSuperview];
        }];
        _menuItems = menuItems;
        [self _recalculateGeometry];
    }
}

#pragma mark - Public Methods

- (void)expandWithCompletion:(DALCircularMenuCompletionBlock)completion
{
    if (!_animationTimer) {
        _currentAnimationIndex = 0;
        _completionBlock = [completion copy];
        _animationTimer = [NSTimer timerWithTimeInterval:self.animationTimeOffset target:self selector:@selector(_expandCurrentAnimationItem) userInfo:nil repeats:YES];
        self.animating = YES;
        [[NSRunLoop currentRunLoop] addTimer:_animationTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)closeWithCompletion:(DALCircularMenuCompletionBlock)completion
{
    if (!_animationTimer) {
        _currentAnimationIndex = [self.menuItems count] - 1;
        _completionBlock = [completion copy];
        _animationTimer = [NSTimer timerWithTimeInterval:self.animationTimeOffset target:self selector:@selector(_closeCurrentAnimationItem) userInfo:nil repeats:YES];
        self.animating = YES;
        [[NSRunLoop currentRunLoop] addTimer:_animationTimer forMode:NSRunLoopCommonModes];
    }
}

#pragma mark - Private

- (void)_expandCurrentAnimationItem
{
    [self _animateCurrentItemReverse:NO];
    _currentAnimationIndex++;
}

- (void)_closeCurrentAnimationItem
{
    [self _animateCurrentItemReverse:YES];
    _currentAnimationIndex--;
}

- (void)_animateCurrentItemReverse:(BOOL)reverse
{
    if (_currentAnimationIndex == [self.menuItems count] || _currentAnimationIndex == -1) {
        [_animationTimer invalidate];
        _animationTimer = nil;
    } else {
        NSUInteger index = _currentAnimationIndex;
        UIButton *button = self.menuItems[index];
        DALCircularMenuLayoutData *data = _layoutData[index];
        CAAnimation *animation = [self _positionAnimationForItemAtIndex:index reverse:reverse];
        if ((index == 0 && reverse) || (index == [self.menuItems count]-1 && !reverse)) {
            [animation setValue:@YES forKey:DALCircularMenuLastAnimationKey];
        }
        [button.layer addAnimation:animation forKey:DALCircularMenuDefaultAnimationKey];
        button.center = reverse ? data.origin : data.destination;
    }
}

- (void)_recalculateGeometry
{
    _layoutData = nil;
    if (![self.menuItems count]) { return; }
    NSUInteger count = [self.menuItems count];
    NSMutableArray *geometry = [NSMutableArray arrayWithCapacity:count];
    [self.menuItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DALCircularMenuLayoutData *data = [DALCircularMenuLayoutData new];
        data.origin = self.animationOrigin;
        data.destination = [self _rotatedPointWithRadius:self.destinationRadius forItemAtIndex:idx];
        CGFloat stretchRadius = self.destinationRadius * self.stretchRatio;
        data.stretchPoint = [self _rotatedPointWithRadius:stretchRadius forItemAtIndex:idx];
        CGFloat compressionRadius = self.destinationRadius * self.compressionRatio;
        data.compressionPoint = [self _rotatedPointWithRadius:compressionRadius forItemAtIndex:idx];
        UIButton *button = (UIButton *)obj;
        button.center = self.animationOrigin;
        [geometry addObject:data];
        [button removeFromSuperview];
        [self addSubview:button];
    }];
    _layoutData = geometry;
}

- (CGPoint)_rotatedPointWithRadius:(CGFloat)radius forItemAtIndex:(NSUInteger)index
{
    CGFloat partialAngle = index * (self.menuAngle / [self.menuItems count]);
    CGPoint point = CGPointMake(self.animationOrigin.x + radius * sinf(partialAngle), self.animationOrigin.y - radius * cosf(partialAngle));
    return DALRotatePointAroundCenter(point, self.animationOrigin, self.itemRotationAngle);
}

#pragma mark - Animations

- (CAKeyframeAnimation *)_positionAnimationForItemAtIndex:(NSUInteger)index reverse:(BOOL)reverse
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.duration = self.animationDuration;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.delegate = self;
    if (reverse) animation.speed = -1;
    CGMutablePathRef path = CGPathCreateMutable();
    DALCircularMenuLayoutData *data = _layoutData[index];
    CGPathMoveToPoint(path, NULL, data.origin.x, data.origin.y);
    CGPathAddLineToPoint(path, NULL, data.stretchPoint.x, data.stretchPoint.y)
    ;
    CGPathAddLineToPoint(path, NULL, data.compressionPoint.x, data.compressionPoint.y);
    CGPathAddLineToPoint(path, NULL, data.destination.x, data.destination.y);
    animation.path = path;
    CGPathRelease(path);
    return animation;
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    if ([[theAnimation valueForKey:DALCircularMenuLastAnimationKey] boolValue]) {
        self.animating = NO;
        if (_completionBlock) {
            _completionBlock(self);
            _completionBlock = nil;
        }
    }
}
@end
