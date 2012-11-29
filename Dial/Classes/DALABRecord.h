//
//  DALABRecord.h
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-29.
//  Copyright (c) 2012 Reactive Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface DALABRecord : NSObject
@property (nonatomic, readonly) ABRecordType recordType;
@property (nonatomic, readonly) ABRecordRef record;
@property (nonatomic, readonly) ABRecordID recordID;

@property (nonatomic, copy, readonly) NSString *compositeName;
- (id)initWithRecord:(ABRecordRef)record;

- (NSArray *)arrayForProperty:(ABPropertyID)property;
- (BOOL)setArray:(NSArray *)array
     forProperty:(ABPropertyID)property
           error:(NSError **)error;

- (id)valueForProperty:(ABPropertyID)property;
- (BOOL)setValue:(id)value
     forProperty:(ABPropertyID)property
           error:(NSError **)error;
@end
