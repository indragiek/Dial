//
//  DALSectionIndexListView.m
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-29.
//  Copyright (c) 2012 Reactive Development. All rights reserved.
//

#import "DALSectionIndexListView.h"
#import "NSShadow+DALAdditions.h"

static CGFloat const DALSectionIndexListViewEdgeInset = 15.f;

@interface DALSectionIndexListView ()
@property (nonatomic, assign) BOOL attributesDirty;
@property (nonatomic, strong, readonly) NSDictionary *textAttributes;
@end

@implementation DALSectionIndexListView {
    NSArray *_layoutRects;
    NSMutableDictionary *_textAttributes;
}
@synthesize textAttributes = _textAttributes;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        _textAttributes = [NSMutableDictionary dictionary];
        NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
        [style setAlignment:NSTextAlignmentCenter];
        _textAttributes[NSParagraphStyleAttributeName] = style;
        self.font = [UIFont boldSystemFontOfSize:11.f];
        self.textColor = [UIColor colorWithRed:0.631 green:0.639 blue:0.647 alpha:1.f];
        self.textShadow = [NSShadow shadowWithColor:[UIColor whiteColor] offset:CGSizeMake(0.f, 1.f) blurRadius:1.f];
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
}

#pragma mark - Accessors

- (void)setSectionIndexTitles:(NSArray *)sectionIndexTitles
{
    if (_sectionIndexTitles != sectionIndexTitles) {
        _sectionIndexTitles = sectionIndexTitles;
        if ([_sectionIndexTitles count]) {
            NSMutableArray *rects = [NSMutableArray arrayWithCapacity:[sectionIndexTitles count]];
            __block CGFloat totalContentHeight = 0.f;
            [_sectionIndexTitles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
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
}

- (UIFont *)font
{
    return _textAttributes[NSFontAttributeName];
}

- (void)setFont:(UIFont *)font
{
    _textAttributes[NSFontAttributeName] = font;
}

- (UIColor *)textColor
{
    return _textAttributes[NSForegroundColorAttributeName];
}

- (void)setTextColor:(UIColor *)textColor
{
    _textAttributes[NSForegroundColorAttributeName] = textColor;
}

- (NSShadow *)shadow
{
    return _textAttributes[NSShadowAttributeName];
}

- (void)setTextShadow:(NSShadow *)textShadow
{
    _textAttributes[NSShadowAttributeName] = textShadow;
}
@end
