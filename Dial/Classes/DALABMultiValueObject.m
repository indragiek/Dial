//
//  DALABMultiValueObject.m
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-27.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "DALABMultiValueObject.h"

@implementation DALABMultiValueObject

- (id)initWithLabel:(NSString *)label
              value:(NSString *)value
         identifier:(NSInteger)identifier
{
    if ((self = [super init])) {
        _label = label;
        _value = value;
        _identifier = identifier;
    }
    return self;
}
@end
