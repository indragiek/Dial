//
//  DALABMultiValueObject.h
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-27.
//  Copyright (c) 2012 Reactive Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface DALABMultiValueObject : NSObject
@property (nonatomic, copy, readonly) NSString *label;
@property (nonatomic, copy, readonly) NSString *value;
@property (nonatomic, readonly) NSInteger identifier;
- (id)initWithLabel:(NSString *)label
              value:(NSString *)value
         identifier:(NSInteger)identifier;
@end
