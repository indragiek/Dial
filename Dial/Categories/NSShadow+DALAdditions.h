//
//  NSShadow+DALAdditions.h
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-29.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSShadow (DALAdditions)
+ (NSShadow *)shadowWithColor:(UIColor *)color
                       offset:(CGSize)offset
                   blurRadius:(CGFloat)radius;
@end
