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