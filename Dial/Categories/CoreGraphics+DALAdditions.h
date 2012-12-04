//
//  CoreGraphics+DALAdditions.h
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-27.
//  Copyright (c) 2012 Reactive Development. All rights reserved.
//

CGRect DALCGRectFlipped(CGRect rect, CGRect bounds);
CGPoint DALCGPointFlipped(CGPoint point, CGRect bounds);
void DALDrawGradientWithColors(NSArray *colors, CGFloat locations[], CGPoint startPoint, CGPoint endPoint);
CGFloat DALDegreesToRadians(CGFloat degrees);
CGFloat DALRadiansToDegrees(CGFloat radians);