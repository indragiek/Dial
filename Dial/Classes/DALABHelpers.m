//
//  DALABHelpers.m
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-27.
//  Copyright (c) 2012 Reactive Development. All rights reserved.
//

#import "DALABHelpers.h"
#import "DALABMultiValueObject.h"

NSArray* DALABMultiValueObjectArrayWithMultiValue(ABMultiValueRef multiValue)
{
    CFIndex count = ABMultiValueGetCount(multiValue);
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:count];
    for (CFIndex i = 0; i < count; i++) {
        NSString *value = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(multiValue, i);
        NSString *label = (__bridge_transfer NSString*)ABMultiValueCopyLabelAtIndex(multiValue, i);
        NSInteger identifier = ABMultiValueGetIdentifierAtIndex(multiValue, i);
        DALABMultiValueObject *obj = [[DALABMultiValueObject alloc] initWithLabel:label value:value identifier:identifier];
        [objects addObject:obj];
    }
    return objects;
}

ABMultiValueRef DALABCreateMultiValueWithArray(ABPropertyType type, NSArray *array)
{
    ABMutableMultiValueRef multiValue = ABMultiValueCreateMutable(type);
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ABMultiValueAddValueAndLabel(multiValue, (__bridge CFStringRef)[(DALABMultiValueObject *)obj value], (__bridge CFStringRef)[obj label], NULL);
    }];
    return multiValue;
}