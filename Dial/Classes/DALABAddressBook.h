//
//  DALABAddressBook.h
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-26.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@class DALABAddressBook;
typedef void(^DALABAddressBookNotificationHandler)(NSDictionary *info);

@interface DALABAddressBook : NSObject
@property (nonatomic, readonly) ABAuthorizationStatus authorizationStatus;
@property (nonatomic, readonly) ABAddressBookRef addressBook;
@property (nonatomic, readonly) BOOL hasUnsavedChanges;

+ (instancetype)addressBook;
- (void)requestAuthorizationWithCompletionHandler:(void(^)(DALABAddressBook *addressBook, BOOL granted, NSError *error))completionHandler;

- (BOOL)save:(NSError **)error;
- (void)revert;

- (void)registerForChangeNotificationsWithHandler:(DALABAddressBookNotificationHandler)handler;
- (void)unregisterForChangeNotifications;

- (NSArray *)allPeople;
@end
