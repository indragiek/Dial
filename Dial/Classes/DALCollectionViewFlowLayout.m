//
//  DALCollectionViewFlowLayout.m
//  Dial
//
//  Created by Indragie Karunaratne on 2012-12-02.
//  Copyright (c) 2012 Reactive Development. All rights reserved.
//

#import "DALCollectionViewFlowLayout.h"

// Fix for cell wrapping bug from <http://stackoverflow.com/questions/12927027/uicollectionview-flowlayout-not-wrapping-cells-correctly-ios>

@implementation DALCollectionViewFlowLayout
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray *newAttributes = [NSMutableArray arrayWithCapacity:attributes.count];
    for (UICollectionViewLayoutAttributes *attribute in attributes) {
        if (attribute.frame.origin.x + attribute.frame.size.width <= self.collectionViewContentSize.width) {
            [newAttributes addObject:attribute];
        }
    }
    return newAttributes;
}
@end
