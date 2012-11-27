//
//  DALABHelpers.h
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-27.
//  Copyright (c) 2012 Reactive Development. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

NSArray* DALABMultiValueObjectArrayWithMultiValue(ABMultiValueRef multiValue);

ABMultiValueRef DALABCreateMultiValueWithArray(ABPropertyType type, NSArray *array);