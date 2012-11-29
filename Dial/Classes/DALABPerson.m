//
//  DALABPerson.m
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-26.
//  Copyright (c) 2012 Reactive Development. All rights reserved.
//

#import "DALABPerson.h"
#import "DALABAddressBook.h"
#import "DALABHelpers.h"

#import "NSMutableArray+DALAdditions.h"

@implementation DALABPerson

- (id)initWithRecord:(ABRecordRef)record linkedPeople:(NSArray *)linked
{
    if ((self = [super init])) {
        _record = record;
        _firstName = (__bridge_transfer NSString*)ABRecordCopyValue(_record, kABPersonFirstNameProperty);
        _lastName = (__bridge_transfer NSString*)ABRecordCopyValue(_record, kABPersonLastNameProperty);
        ABMultiValueRef emails = ABRecordCopyValue(_record, kABPersonEmailProperty);
        _emails = DALABMultiValueObjectArrayWithMultiValue(emails);
        ABMultiValueRef phones = ABRecordCopyValue(_record, kABPersonPhoneProperty);
        _phoneNumbers = DALABMultiValueObjectArrayWithMultiValue(phones);
        CFRelease(emails);
        CFRelease(phones);
        _linkedPeople = linked;
        [self _mergeLinkedPeople];
    }
    return self;
}

#pragma mark - Accessors

- (NSString *)identifier
{
    return [@(ABRecordGetRecordID(_record)) stringValue];
}

- (void)setFirstName:(NSString *)firstName
{
    ABRecordSetValue(_record, kABPersonFirstNameProperty, (__bridge CFStringRef)firstName, NULL);
}

- (void)setLastName:(NSString *)lastName
{
    ABRecordSetValue(_record, kABPersonLastNameProperty, (__bridge CFStringRef)lastName, NULL);
}

- (void)setEmail:(NSString *)email
{
    ABRecordSetValue(_record, kABPersonEmailProperty, (__bridge CFStringRef)email, NULL);
}

- (void)setPhoneNumbers:(NSArray *)phoneNumbers
{
    ABMultiValueRef multiValue = DALABCreateMultiValueWithArray(kABMultiStringPropertyType, phoneNumbers);
    ABRecordSetValue(_record, kABPersonPhoneProperty, multiValue, NULL);
    CFRelease(multiValue);
}

- (void)setEmails:(NSArray *)emails
{
    ABMultiValueRef multiValue = DALABCreateMultiValueWithArray(kABMultiStringPropertyType, emails);
    ABRecordSetValue(_record, kABPersonEmailProperty, multiValue, NULL);
    CFRelease(multiValue);
}

- (BOOL)hasImageData
{
    return ABPersonHasImageData(_record);
}

- (NSData *)imageData
{
    if (self.hasImageData) {
        return (__bridge NSData*)ABPersonCopyImageData(_record);
    } else if ([self.linkedPeople count]) {
        __block NSData *imageData = nil;
        [self.linkedPeople enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj hasImageData]) {
                imageData = [obj imageData];
                *stop = YES;
            }
        }];
        return imageData;
    }
    return nil;
}

- (void)setImageData:(NSData *)imageData
{
    ABPersonSetImageData(_record, (__bridge CFDataRef)imageData, NULL);
}

- (void)_mergeLinkedPeople
{
    NSMutableArray *emails = [NSMutableArray arrayWithArray:self.emails];
    NSMutableArray *phones = [NSMutableArray arrayWithArray:self.phoneNumbers];
    [self.linkedPeople enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [emails addObjectsFromArray:[obj emails]];
        [phones addObjectsFromArray:[obj phoneNumbers]];
    }];
    [emails removeDuplicates];
    [phones removeDuplicates];
    _emails = emails;
    _phoneNumbers = phones;
}

@end
