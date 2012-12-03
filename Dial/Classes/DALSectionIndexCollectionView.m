//
//  DALSectionIndexCollectionView.m
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-29.
//  Copyright (c) 2012 Reactive Development. All rights reserved.
//

#import "DALSectionIndexCollectionView.h"
#import "DALSectionIndexListView.h"

CGFloat const DALSectionIndexListViewWidth = 32.f;

@implementation DALSectionIndexCollectionView {
    DALSectionIndexListView *_indexListView;
}
@dynamic dataSource, delegate;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        _indexListView = [[DALSectionIndexListView alloc] initWithFrame:CGRectZero];
        _indexListView.collectionView = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
    }
    return self;
}

#pragma mark - Accessors

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [_indexListView removeFromSuperview];
    CGRect listViewFrame = CGRectMake(CGRectGetMaxX(self.frame) - DALSectionIndexListViewWidth, CGRectGetMinY(self.frame), DALSectionIndexListViewWidth, CGRectGetHeight(self.frame));
    _indexListView.frame = listViewFrame;
    _indexListView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [[self superview] addSubview:_indexListView];
}

- (void)reloadData
{
    [super reloadData];
    if ([self.dataSource respondsToSelector:@selector(sectionIndexTitlesForCollectionView:)]) {
        NSArray *titles = [self.dataSource sectionIndexTitlesForCollectionView:self];
        NSUInteger numberOfTitles = [titles count];
        NSUInteger numberOfSections = [self numberOfSections];
        if (numberOfTitles && numberOfTitles != numberOfSections) {
            NSLog(@"**WARNING**: Number of section index titles returned does not match the number of sections (%u vs %u)", numberOfTitles, numberOfSections);
        }
        _indexListView.sectionIndexTitles = titles;
    }
}
@end
