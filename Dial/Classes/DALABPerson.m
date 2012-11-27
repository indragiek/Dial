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
@synthesize imageData = _imageData;

- (id)initWithRecord:(ABRecordRef)record
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
    }
    return self;
}

+ (instancetype)personWithRecord:(ABRecordRef)record
{
    DALABPerson *person = [[DALABPerson alloc] initWithRecord:record];
    return person;
}

#pragma mark - Accessors

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
}

- (void)setEmails:(NSArray *)emails
{
    ABMultiValueRef multiValue = DALABCreateMultiValueWithArray(kABMultiStringPropertyType, emails);
    ABRecordSetValue(_record, kABPersonEmailProperty, multiValue, NULL);
}

- (NSData *)imageData
{
    if (!_imageData && ABPersonHasImageData(_record))
        _imageData = (__bridge_transfer NSData*)ABPersonCopyImageData(_record);
    return _imageData;
}

- (void)setImageData:(NSData *)imageData
{
    ABPersonSetImageData(_record, (__bridge CFDataRef)imageData, NULL);
}

- (void)mergePerson:(DALABPerson *)person
{
    NSMutableArray *emails = [NSMutableArray arrayWithArray:self.emails];
    NSMutableArray *phones = [NSMutableArray arrayWithArray:self.phoneNumbers];
    [emails addObjectsFromArray:person.emails];
    [phones addObjectsFromArray:person.phoneNumbers];
    [emails removeDuplicates];
    [phones removeDuplicates];
    _emails = emails;
    _phoneNumbers = phones;
}
@end
