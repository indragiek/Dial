//
//  CoreGraphics+DALAdditions.m
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-27.
//  Copyright (c) 2012 Reactive Development. All rights reserved.
//

#import "CoreGraphics+DALAdditions.h"

CGRect DALCGRectFlipped(CGRect rect, CGRect bounds)
{
    return CGRectMake(CGRectGetMinX(rect),
                      CGRectGetMaxY(bounds) - CGRectGetMaxY(rect),
                      CGRectGetWidth(rect),
                      CGRectGetHeight(rect));
}

CGPoint DALCGPointFlipped(CGPoint point, CGRect bounds)
{
    return CGPointMake(point.x, CGRectGetMaxY(bounds) - point.y);
}

void DALDrawGradientWithColors(NSArray *colors, CGFloat locations[], CGPoint startPoint, CGPoint endPoint)
{
    NSMutableArray *CGColors = [NSMutableArray array];
    [colors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [CGColors addObject:(__bridge id)[obj CGColor]];
    }];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)CGColors, locations);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}