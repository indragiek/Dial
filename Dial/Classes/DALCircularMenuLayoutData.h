//
//  DALCircularMenuLayoutData.h
//  Dial
//
//  Created by Indragie Karunaratne on 2012-12-01.
//  Copyright (c) 2012 Reactive Development. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 
 Layout data for the animation sequence of a single menu item
 Follows this sequence: [origin] -> [stretch point] -> [compression point] -> [destination]
 */

@interface DALCircularMenuLayoutData : NSObject
/** The point at which the item originates from */
@property (nonatomic, assign) CGPoint origin;
/** The point at which the item ends at after the animation */
@property (nonatomic, assign) CGPoint destination;
/** The furthest point that the item animates to. It animates 
 to this point as soon as it leaves the origin */
@property (nonatomic, assign) CGPoint stretchPoint;
/** The nearest point from the origin that the item animates to. It
 animates to this point right after animating to the stretch point. */
@property (nonatomic, assign) CGPoint compressionPoint;
@end
