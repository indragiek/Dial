//
//  DALABRecord.m
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-29.
//  Copyright (c) 2012 Reactive Development. All rights reserved.
//

#import "DALABRecord.h"
#import "DALABMultiValueObject.h"

@implementation DALABRecord

- (id)initWithRecord:(ABRecordRef)record
{
    if ((self = [super init])) {
        _record = record;
    }
    return self;
}

#pragma mark - Accessors

- (ABRecordType)recordType
{
    return ABRecordGetRecordType(_record);
}

- (ABRecordID)recordID
{
    return ABRecordGetRecordID(_record);
}

- (NSString *)compositeName
{
    return (__bridge_transfer NSString *)ABRecordCopyCompositeName(_record);
}

- (BOOL)setArray:(NSArray *)array
     forProperty:(ABPropertyID)property
           error:(NSError **)error
{
    ABMutableMultiValueRef multiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ABMultiValueAddValueAndLabel(multiValue, (__bridge CFStringRef)[(DALABMultiValueObject *)obj value], (__bridge CFStringRef)[obj label], NULL);
    }];
    CFErrorRef theError = NULL;
    bool success = ABRecordSetValue(_record, property, multiValue, &theError);
    if (error)
        *error = (__bridge NSError *)theError;
    CFRelease(multiValue);
    return (BOOL)success;
}


- (NSArray *)arrayForProperty:(ABPropertyID)property
{
    ABMultiValueRef multiValue = ABRecordCopyValue(_record, property);
    CFIndex count = ABMultiValueGetCount(multiValue);
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:count];
    for (CFIndex i = 0; i < count; i++) {
        NSString *value = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(multiValue, i);
        NSString *label = (__bridge_transfer NSString*)ABMultiValueCopyLabelAtIndex(multiValue, i);
        NSInteger identifier = ABMultiValueGetIdentifierAtIndex(multiValue, i);
        DALABMultiValueObject *obj = [[DALABMultiValueObject alloc] initWithLabel:label value:value identifier:identifier];
        [objects addObject:obj];
    }
    CFRelease(multiValue);
    return objects;
}

- (id)valueForProperty:(ABPropertyID)property
{
    return (__bridge_transfer id)ABRecordCopyValue(_record, property);
}

- (BOOL)setValue:(id)value
     forProperty:(ABPropertyID)property
           error:(NSError **)error
{
    CFErrorRef theError = NULL;
    bool success = ABRecordSetValue(_record, property, (__bridge CFTypeRef)value, &theError);
    if (error)
        *error = (__bridge NSError *)theError;
    return (BOOL)success;
}
@end
