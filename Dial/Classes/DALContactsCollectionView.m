//
//  DALContactsCollectionView.m
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-29.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "DALContactsCollectionView.h"
#import "DALCollectionViewFlowLayout.h"

static CGFloat const DALContactsLayoutMinimumLineSpacing = 21.f;
static CGFloat const DALContactsLayoutMinimumInteritemSpacing = 15.f;
static CGFloat const DALContactsLayoutItemWidth = 81.f;
static CGFloat const DALContactsLayoutItemHeight = 121.f;
static CGFloat const DALContactsLongPresssDuration = 0.25f;
static NSString* const DALContactsBackgroundPatternImageName = @"bg";
static CGFloat const DALContactsLayoutSectionHeaderHeight = 30.f;

@implementation DALContactsCollectionView
@dynamic delegate;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:DALContactsBackgroundPatternImageName]];
        DALCollectionViewFlowLayout *layout = [DALCollectionViewFlowLayout new];
        layout.minimumLineSpacing = DALContactsLayoutMinimumLineSpacing;
        layout.minimumInteritemSpacing = DALContactsLayoutMinimumInteritemSpacing;
        layout.itemSize = CGSizeMake(DALContactsLayoutItemWidth, DALContactsLayoutItemHeight);
        layout.sectionInset = UIEdgeInsetsMake(DALContactsLayoutMinimumLineSpacing, DALContactsLayoutMinimumInteritemSpacing, DALContactsLayoutMinimumLineSpacing, DALSectionIndexListViewWidth);
        layout.headerReferenceSize = CGSizeMake(CGRectGetWidth(self.bounds), DALContactsLayoutSectionHeaderHeight);
        self.collectionViewLayout = layout;
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_handleLongPress:)];
        longPress.minimumPressDuration = DALContactsLongPresssDuration;
        [self addGestureRecognizer:longPress];
    }
    return self;
}

#pragma mark - Event Handling

- (void)_handleLongPress:(UIGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint location = [recognizer locationInView:self];
        NSIndexPath *indexPath = [self indexPathForItemAtPoint:location];
        if (indexPath && [self.delegate respondsToSelector:@selector(collectionView:longPressOnCellAtIndexPath:atPoint:)]) {
            UICollectionViewCell *cell = [self cellForItemAtIndexPath:indexPath];
            CGPoint location = [recognizer locationInView:cell];
            [self.delegate collectionView:self longPressOnCellAtIndexPath:indexPath atPoint:location];
        }
    }
}

@end
