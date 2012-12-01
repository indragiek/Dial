//
//  UIView+DALAdditions.m
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-30.
//  Copyright (c) 2012 Reactive Development. All rights reserved.
//

#import "UIView+DALAdditions.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (DALAdditions)
- (UIImage*)UIImage
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, [[UIScreen mainScreen] scale]);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
