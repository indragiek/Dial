//
//  DALContactsSectionHeaderView.m
//  Dial
//
//  Created by Indragie Karunaratne on 2012-12-02.
//  Copyright (c) 2012 Reactive Development. All rights reserved.
//

#import "DALContactSectionHeaderView.h"
#import "CoreGraphics+DALAdditions.h"

#define DALContactsSectionHeaderViewBottomColor [UIColor colorWithRed:0.847f green:0.855f blue:0.859f alpha:1.f]
#define DALContactsSectionHeaderViewTopColor [UIColor colorWithRed:0.910f green:0.918f blue:0.925f alpha:1.f]
#define DALContactsSectionHeaderViewBottomBorderColor [UIColor colorWithRed:0.741f green:0.741f blue:0.741f alpha:1.f]
#define DALContactsSectionHeaderViewTopBorderColor [UIColor colorWithRed:0.804f green:0.804f blue:0.804f alpha:1.f]
#define DALContactsSectionHeaderViewHighlightColor [UIColor colorWithWhite:1.f alpha:0.5f]

@implementation DALContactSectionHeaderView

- (void)drawRect:(CGRect)rect
{
    CGFloat width = CGRectGetWidth(self.bounds);
    CGRect topBorder = CGRectMake(0.f, 0.f, width, 1.f);
    CGRect highlight = CGRectMake(0.f, 1.f, width, 1.f);
    CGRect bottomBorder = CGRectMake(0.f, CGRectGetMaxY(self.bounds) - 1.f, width, 1.f);
    CGRect gradientRect = CGRectMake(0.f, 1.f, width, CGRectGetHeight(self.bounds) - 2.f);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(gradientRect), CGRectGetMaxY(gradientRect));
    CGPoint endPoint = CGPointMake(startPoint.x, CGRectGetMinY(gradientRect));
    CGFloat locations[2] = {0.0, 1.0};
    DALDrawGradientWithColors(@[DALContactsSectionHeaderViewBottomColor, DALContactsSectionHeaderViewTopColor], locations, startPoint, endPoint);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, DALContactsSectionHeaderViewTopBorderColor.CGColor);
    CGContextFillRect(ctx, topBorder);
    CGContextSetFillColorWithColor(ctx, DALContactsSectionHeaderViewBottomBorderColor.CGColor);
    CGContextFillRect(ctx, bottomBorder);
    CGContextSetFillColorWithColor(ctx, DALContactsSectionHeaderViewHighlightColor.CGColor);
    CGContextFillRect(ctx, highlight);
}

@end
