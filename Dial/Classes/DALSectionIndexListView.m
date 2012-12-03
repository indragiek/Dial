//
//  DALSectionIndexListView.m
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-29.
//  Copyright (c) 2012 Reactive Development. All rights reserved.
//

#import "DALSectionIndexListView.h"
#import "DALSectionIndexCollectionView.h"
#import "NSShadow+DALAdditions.h"

static CGFloat const DALSectionIndexListViewEdgeInset = 15.f;

#define DALSectionIndexListDefaultFont [UIFont boldSystemFontOfSize:11.f]
#define DALSectionIndexListDefaultTextColor [UIColor colorWithRed:0.631f green:0.639f blue:0.647f alpha:1.f]
#define DALSectionIndexListDefaultHighlightedTextColor [UIColor colorWithRed:0.431f green:0.439f blue:0.451f alpha:1.f]
#define DALSectionIndexListDefaultTextShadow [NSShadow shadowWithColor:[UIColor whiteColor] offset:CGSizeMake(0.f, 1.f) blurRadius:1.f]

#define DALSectionIndexListBubbleColor [UIColor colorWithWhite:0.f alpha:0.5f]
static CGFloat const DALSectionIndexListBubbleYInset = 6.f;
static CGFloat const DALSectionIndexListBubbleWidth = 28.f;

@interface DALSectionIndexListView ()
@property (nonatomic, assign, readwrite, getter = isHighlighted) BOOL highlighted;
@end

@implementation DALSectionIndexListView {
    NSArray *_layoutRects;
    NSMutableDictionary *_textAttributes;
    UIColor *_textColor;
    UIColor *_highlightedTextColor;
    id _lastNotifiedIndexTitle;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        _textAttributes = [NSMutableDictionary dictionary];
        NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
        [style setAlignment:NSTextAlignmentCenter];
        _textAttributes[NSParagraphStyleAttributeName] = style;
        self.font = DALSectionIndexListDefaultFont;
        self.textColor = DALSectionIndexListDefaultTextColor;
        self.highlightedTextColor = DALSectionIndexListDefaultHighlightedTextColor;
        self.textShadow = DALSectionIndexListDefaultTextShadow;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [_sectionIndexTitles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGRect rect = [[_layoutRects objectAtIndex:idx] CGRectValue];
        if ([obj isKindOfClass:[NSString class]]) {
            NSAttributedString *string = [[NSAttributedString alloc] initWithString:obj attributes:_textAttributes];
            [string drawInRect:rect];
        } else if ([obj isKindOfClass:[UIImage class]]) {
            [obj drawInRect:rect];
        }
    }];
    if (self.highlighted) {
        CGFloat widthInset = (CGRectGetWidth(self.bounds) - DALSectionIndexListBubbleWidth) / 2.f;
        CGRect bubbleRect = CGRectInset(self.bounds, widthInset, DALSectionIndexListBubbleYInset);
        CGFloat radius = CGRectGetWidth(bubbleRect) / 2.f;
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:bubbleRect cornerRadius:radius];
        [DALSectionIndexListBubbleColor set];
        [path fill];
    }
}

#pragma mark - Touch Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = YES;
    CGPoint point = [[touches anyObject] locationInView:self];
    [self _notifyDelegateWithTappedPoint:point];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self];
    [self _notifyDelegateWithTappedPoint:point];
}

- (void)_notifyDelegateWithTappedPoint:(CGPoint)point
{
    id<DALSectionIndexCollectionViewDelegate> delegate = self.collectionView.delegate;
    if ([delegate respondsToSelector:@selector(collectionView:tappedSectionIndexTitle:)]) {
        CGFloat width = CGRectGetWidth(self.bounds);
        [_layoutRects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            CGRect rect = [obj CGRectValue];
            rect.size.width = width;
            if (CGRectContainsPoint(rect, point)) {
                id title = self.sectionIndexTitles[idx];
                if (_lastNotifiedIndexTitle != title) {
                    _lastNotifiedIndexTitle = title;
                    [delegate collectionView:self.collectionView tappedSectionIndexTitle:title];
                }
                *stop = YES;
            }
        }];
    }
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self _recalculateGeometry];
}

- (void)_recalculateGeometry
{
    if ([self.sectionIndexTitles count]) {
        NSMutableArray *rects = [NSMutableArray arrayWithCapacity:[self.sectionIndexTitles count]];
        __block CGFloat totalContentHeight = 0.f;
        [self.sectionIndexTitles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[NSString class]]) {
                CGFloat textHeight = [obj sizeWithFont:self.font].height;
                totalContentHeight += textHeight;
                CGRect textRect = CGRectMake(0.f, 0.f, CGRectGetWidth(self.bounds), textHeight);
                NSValue *value = [NSValue valueWithCGRect:textRect];
                [rects addObject:value];
            } else if ([obj isKindOfClass:[UIImage class]]) {
                CGSize imageSize = [(UIImage *)obj size];
                totalContentHeight += imageSize.height;
                CGRect imageRect = CGRectMake(floor(CGRectGetMidX(self.bounds) - (imageSize.width / 2.f)), 0.f, imageSize.width, imageSize.height);
                NSValue *value = [NSValue valueWithCGRect:imageRect];
                [rects addObject:value];
            }
        }];
        CGFloat margin = (CGRectGetHeight(self.bounds) - totalContentHeight - (DALSectionIndexListViewEdgeInset * 2.f)) / [rects count];
        NSMutableArray *adjustedRects = [NSMutableArray arrayWithCapacity:[rects count]];
        __block CGFloat currentOrigin = DALSectionIndexListViewEdgeInset;
        [rects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            CGRect rect = [obj CGRectValue];
            rect.origin.y = currentOrigin;
            currentOrigin += CGRectGetHeight(rect) + margin;
            NSValue *value = [NSValue valueWithCGRect:rect];
            [adjustedRects addObject:value];
        }];
        _layoutRects = adjustedRects;
    } else {
        _layoutRects = nil;
    }
    [self setNeedsDisplay];
}

#pragma mark - Accessors

- (void)setFont:(UIFont *)font
{
    if (_font != font) {
        _font = font;
        _textAttributes[NSFontAttributeName] = font;
    }
}

- (void)setTextShadow:(NSShadow *)textShadow
{
    if (_textShadow != textShadow) {
        _textShadow = textShadow;
        _textAttributes[NSShadowAttributeName] = textShadow;
    }
}

- (void)setTextColor:(UIColor *)textColor
{
    if (_textColor != textColor) {
        _textColor = textColor;
        [self _resetTextColor];
    }
}

- (void)setHighlightedTextColor:(UIColor *)highlightedTextColor
{
    if (_highlightedTextColor != highlightedTextColor) {
        _highlightedTextColor = highlightedTextColor;
        [self _resetTextColor];
    }
}

- (void)setSectionIndexTitles:(NSArray *)sectionIndexTitles
{
    if (_sectionIndexTitles != sectionIndexTitles) {
        _lastNotifiedIndexTitle = nil;
        _sectionIndexTitles = sectionIndexTitles;
        [self _recalculateGeometry];
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    if (_highlighted != highlighted) {
        _highlighted = highlighted;
        [self _resetTextColor];
        [self setNeedsDisplay];
    }
}

#pragma mark - Private

- (void)_resetTextColor
{
    if (self.highlighted && self.highlightedTextColor) {
        _textAttributes[NSForegroundColorAttributeName] = self.highlightedTextColor;
    } else if (!self.highlighted && self.textColor) {
        _textAttributes[NSForegroundColorAttributeName] = self.textColor;
    }
}
@end
