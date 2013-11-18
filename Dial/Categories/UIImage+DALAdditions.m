//
//  UIImage+DALAdditions.m
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-27.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "UIImage+DALAdditions.h"
#import "CoreGraphics+DALAdditions.h"

@implementation UIImage (DALAdditions)
- (UIImage *)circularImageCroppedToFaceWithWidth:(CGFloat)width
{
    // Scale for retina displays
    CGFloat scale = [[UIScreen mainScreen] scale];
    CIImage *image = [CIImage imageWithCGImage:self.CGImage];
    CIDetector *faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace
                                                  context:nil
                                                  options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
    NSArray *faces = [faceDetector featuresInImage:image];
    // Crop the image to the width of the shortest axis
    CGFloat cropWidth = MIN(self.size.width, self.size.height);
    CGRect imageBounds = (CGRect){CGPointZero, self.size};
    CGRect cropRect = CGRectIntegral(CGRectMake(CGRectGetMidX(imageBounds) - (cropWidth / 2.f), CGRectGetMidY(imageBounds) - (cropWidth / 2.f), cropWidth, cropWidth));
    if (NO) {
        // Only taking into consideration a single face here
        // Probably should design this to handle cases where there are multiple faces as well
        CIFaceFeature *face = faces[0];
        CGRect imageBounds = (CGRect){CGPointZero, {width, width}};
        CGRect faceBounds = DALCGRectFlipped(face.bounds, cropRect);
        // We're going to assume here that on average, the height of
        // the face recognized by the detector constitutes about 2/3 of the
        // height of the whole head
        CGFloat marginalHeadHeight = CGRectGetHeight(faceBounds) / 3.f;
        CGRect headBounds = faceBounds;
        headBounds.origin.y -= marginalHeadHeight;
        headBounds.size.height += marginalHeadHeight;
        // Outset the rect a bit so that ears, hair, etc. are less likely to be cut off
        headBounds = CGRectInset(headBounds, 20.f, 15.f);
        // Calculate the maximum width of the ellipse based on the bounds of the head
        // and the bounding rectangle of the image itself
        CGFloat maxImageWidth = MIN(CGRectGetWidth(imageBounds), CGRectGetHeight(imageBounds));
        CGFloat maxHeadWidth = MIN(CGRectGetWidth(headBounds), CGRectGetHeight(headBounds));
        CGFloat ellipseWidth = MIN(maxHeadWidth, maxImageWidth);
        // Create the cropping rectangle
        cropRect = CGRectMake(CGRectGetMidX(cropRect) - (ellipseWidth / 2.f),
                              CGRectGetMidY(cropRect) - (ellipseWidth / 2.f),
                              ellipseWidth, ellipseWidth);
    }
    // Scale the image down to the given width
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, width), NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGRect scaledRect = CGRectMake(0.f, 0.f, width, width);
    [self drawInRect:scaledRect fromRect:cropRect blendMode:kCGBlendModeNormal alpha:1.f];
    UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return croppedImage;
}

- (void)drawInRect:(CGRect)drawRect
          fromRect:(CGRect)fromRect
         blendMode:(CGBlendMode)blendMode
             alpha:(CGFloat)alpha
{
    CGImageRef drawImage = CGImageCreateWithImageInRect(self.CGImage, fromRect);
    if (drawImage != NULL) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context);
        CGContextSetBlendMode(context, blendMode);
        CGContextSetAlpha(context, alpha);
        CGContextTranslateCTM(context, 0.0, drawRect.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextDrawImage(context, drawRect, drawImage);
        CGImageRelease(drawImage);
        CGContextRestoreGState(context);
    }
}

- (UIImage *)imageCroppedToEllipse
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect ellipseRect = CGRectMake(0.f, 0.f, self.size.width, self.size.height);
    CGContextAddEllipseInRect(ctx, ellipseRect);
    CGContextClip(ctx);
    [self drawInRect:ellipseRect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
