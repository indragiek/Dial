//
//  DALABAddressBook.m
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-26.
//  Copyright (c) 2012 Reactive Development. All rights reserved.
//

#import "DALABAddressBook.h"
#import "DALABPerson.h"

static DALABAddressBookNotificationHandler _changeHandler = nil;

@implementation DALABAddressBook

- (id)initWithError:(NSError **)error
{
    if ((self = [super init])) {
        CFErrorRef theError = NULL;
        _addressBook = ABAddressBookCreateWithOptions(NULL, &theError);
        if (error)
            *error = (__bridge NSError*)theError;
    }
    return self;
}

+ (instancetype)addressBook
{
    static DALABAddressBook *addressBook = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        addressBook = [[self alloc] initWithError:nil];
    });
    return addressBook;
}

- (ABAuthorizationStatus)authorizationStatus
{
    return ABAddressBookGetAuthorizationStatus();
}

- (BOOL)hasUnsavedChanges
{
    return ABAddressBookHasUnsavedChanges(_addressBook);
}

- (void)requestAuthorizationWithCompletionHandler:(void(^)(DALABAddressBook *addressBook, BOOL granted, NSError *error))completionHandler
{
    ABAddressBookRequestAccessWithCompletion(_addressBook, ^(bool granted, CFErrorRef error) {
        if (completionHandler)
            completionHandler(self, (BOOL)granted, (__bridge NSError*)error);
    });
}

- (void)save:(NSError **)error
{
    CFErrorRef theError = NULL;
    ABAddressBookSave(_addressBook, &theError);
    if (error)
        *error = (__bridge NSError*)theError;
}

- (void)revert
{
    ABAddressBookRevert(_addressBook);
}

void DALExternalChangeCallback(ABAddressBookRef addressBook, CFDictionaryRef info, void *context)
{
    _changeHandler((__bridge NSDictionary*)info);
}

- (void)registerForChangeNotificationsWithHandler:(DALABAddressBookNotificationHandler)handler
{
    _changeHandler = [handler copy];
    ABAddressBookRegisterExternalChangeCallback(_addressBook, DALExternalChangeCallback, NULL);
}

- (void)unregisterForChangeNotifications
{
    _changeHandler = nil;
    ABAddressBookUnregisterExternalChangeCallback(_addressBook, DALExternalChangeCallback, NULL);
}

#pragma mark - People

// <http://stackoverflow.com/questions/4067542/getting-merged-unified-entries-from-abaddressbook>

- (NSArray *)allPeople
{
    CFArrayRef records = ABAddressBookCopyArrayOfAllPeople(_addressBook);
    CFMutableArrayRef recordsMutable = CFArrayCreateMutableCopy(kCFAllocatorDefault, CFArrayGetCount(records), records);
    CFArraySortValues(recordsMutable, CFRangeMake(0, CFArrayGetCount(recordsMutable)), (CFComparatorFunction)ABPersonComparePeopleByName, (void *)ABPersonGetSortOrdering());
    CFRelease(records);
    NSArray *bridgedRecords = (__bridge_transfer NSArray*)recordsMutable;
    NSMutableArray *people = [NSMutableArray arrayWithCapacity:[bridgedRecords count]];
    NSMutableSet *skip = [NSMutableSet set];
    [bridgedRecords enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![skip member:obj]) {
            DALABPerson *person = [DALABPerson personWithRecord:(__bridge ABRecordRef)obj];
            NSArray *linked = (__bridge_transfer NSArray*)ABPersonCopyArrayOfAllLinkedPeople((__bridge ABRecordRef)obj);
            if ([linked count] > 1) {
                [skip addObjectsFromArray:linked];
                [linked enumerateObjectsUsingBlock:^(id obj1, NSUInteger idx1, BOOL *stop1) {
                    DALABPerson *linkedPerson = [DALABPerson personWithRecord:(__bridge ABRecordRef)obj];
                    [person mergePerson:linkedPerson];
                }];
            }
            [people addObject:person];
        }
    }];
    return people;
}
@end
