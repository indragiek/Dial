//
//  DALABPerson.h
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-26.
//  Copyright (c) 2012 Reactive Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface DALABPerson : NSObject
+ (instancetype)personWithRecord:(ABRecordRef)record;

@property (nonatomic, readonly) ABRecordRef record;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSArray *emails;
@property (nonatomic, copy) NSArray *phoneNumbers;
@property (nonatomic, copy) NSData *imageData;
@end
