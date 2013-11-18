//
//  NSMutableArray+DALAdditions.m
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-27.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "NSMutableArray+DALAdditions.h"

@implementation NSMutableArray (DALAdditions)

// <http://stackoverflow.com/questions/1025674/the-best-way-to-remove-duplicate-values-from-nsmutablearray-in-objective-c>

- (void)removeDuplicates
{
    NSMutableSet *seen = [NSMutableSet set];
    NSUInteger i = 0;
    while (i < [self count]) {
        id obj = [self objectAtIndex:i];
        if ([seen containsObject:obj]) {
            [self removeObjectAtIndex:i];
        } else {
            [seen addObject:obj];
            i++;
        }
    }
}
@end
