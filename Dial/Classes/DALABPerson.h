//
//  DALABPerson.h
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-26.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DALABRecord.h"

@interface DALABPerson : DALABRecord
- (id)initWithRecord:(ABRecordRef)record linkedPeople:(NSArray *)linked;

@property (nonatomic, readonly) NSArray *linkedPeople;
@property (nonatomic, readonly) BOOL hasImageData;

@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSArray *emails;
@property (nonatomic, copy) NSArray *phoneNumbers;
@property (nonatomic, copy) NSData *imageData;
@end
