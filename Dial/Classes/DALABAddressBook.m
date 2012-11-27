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

- (NSArray *)allPeople
{
    NSArray *records = (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeople(_addressBook);
    NSMutableArray *people = [NSMutableArray arrayWithCapacity:[records count]];
    for (id record in records) {
        DALABPerson *person = [DALABPerson personWithRecord:(__bridge ABRecordRef)record];
        [people addObject:person];
    }
    return people;
}
@end
