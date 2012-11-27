//
//  DALABPerson.m
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-26.
//  Copyright (c) 2012 Reactive Development. All rights reserved.
//

#import "DALABPerson.h"
#import "DALABAddressBook.h"

@implementation DALABPerson
@synthesize imageData = _imageData;

- (id)initWithRecord:(ABRecordRef)record
{
    if ((self = [super init])) {
        _record = record;
        _firstName = (__bridge_transfer NSString*)ABRecordCopyValue(_record, kABPersonFirstNameProperty);
        _lastName = (__bridge_transfer NSString*)ABRecordCopyValue(_record, kABPersonLastNameProperty);
        _email = (__bridge_transfer NSString*)ABRecordCopyValue(_record, kABPersonEmailProperty);
        if (ABPersonHasImageData(_record)) {
            
        }
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
@end
