//
//  NSShadow+DALAdditions.m
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-29.
//  Copyright (c) 2012 Reactive Development. All rights reserved.
//

#import "NSShadow+DALAdditions.h"

@implementation NSShadow (DALAdditions)
+ (NSShadow *)shadowWithColor:(UIColor *)color
                       offset:(CGSize)offset
                   blurRadius:(CGFloat)radius
{
    NSShadow *shadow = [NSShadow new];
    [shadow setShadowColor:color];
    [shadow setShadowOffset:offset];
    [shadow setShadowBlurRadius:radius];
    return shadow;
}
@end
