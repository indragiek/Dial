//
//  DALABPerson.m
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-26.
//  Copyright (c) 2012 Reactive Development. All rights reserved.
//

#import "DALABPerson.h"
#import "DALABAddressBook.h"

#import "NSMutableArray+DALAdditions.h"

@implementation DALABPerson

- (id)initWithRecord:(ABRecordRef)record linkedPeople:(NSArray *)linked
{
    if ((self = [super initWithRecord:record])) {
        _firstName = [self valueForProperty:kABPersonFirstNameProperty];
        _lastName = [self valueForProperty:kABPersonLastNameProperty];
        _emails = [self arrayForProperty:kABPersonEmailProperty];
        _phoneNumbers = [self arrayForProperty:kABPersonPhoneProperty];
        _linkedPeople = linked;
        [self _mergeLinkedPeople];
    }
    return self;
}

#pragma mark - Accessors

- (void)setFirstName:(NSString *)firstName
{
    [self setValue:firstName forProperty:kABPersonFirstNameProperty error:nil];
}

- (void)setLastName:(NSString *)lastName
{
    [self setValue:lastName forProperty:kABPersonLastNameProperty error:nil];
}

- (void)setPhoneNumbers:(NSArray *)phoneNumbers
{
    [self setArray:phoneNumbers forProperty:kABPersonPhoneProperty error:nil];
}

- (void)setEmails:(NSArray *)emails
{
    [self setArray:emails forProperty:kABPersonEmailProperty error:nil];
}

- (BOOL)hasImageData
{
    return ABPersonHasImageData(self.record);
}

- (NSData *)imageData
{
    if (self.hasImageData) {
        return (__bridge NSData*)ABPersonCopyImageData(self.record);
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
    ABPersonSetImageData(self.record, (__bridge CFDataRef)imageData, NULL);
}

#pragma mark - Private

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
