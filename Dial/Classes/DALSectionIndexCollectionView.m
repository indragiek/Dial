//
//  DALSectionIndexCollectionView.m
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-29.
//  Copyright (c) 2012 Reactive Development. All rights reserved.
//

#import "DALSectionIndexCollectionView.h"
#import "DALSectionIndexListView.h"

static CGFloat const DALSectionIndexListViewWidth = 32.f;

@implementation DALSectionIndexCollectionView {
    DALSectionIndexListView *_indexListView;
}
@dynamic delegate;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        _indexListView = [[DALSectionIndexListView alloc] initWithFrame:CGRectZero];
        _indexListView.backgroundColor = self.backgroundColor;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
    }
    return self;
}

#pragma mark - Accessors

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    _indexListView.backgroundColor = backgroundColor;
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [_indexListView removeFromSuperview];
    CGRect collectionViewFrame, listViewFrame;
    NSLog(@"%@", NSStringFromCGRect(self.frame));
    CGRectDivide(self.frame, &listViewFrame, &collectionViewFrame, DALSectionIndexListViewWidth, CGRectMaxXEdge);
    self.frame = collectionViewFrame;
    _indexListView.frame = listViewFrame;
    [[self superview] addSubview:_indexListView];
}

- (void)reloadData
{
    [super reloadData];
    if ([self.delegate respondsToSelector:@selector(sectionIndexTitlesForCollectionView:)]) {
        NSArray *titles = [self.delegate sectionIndexTitlesForCollectionView:self];
        NSUInteger numberOfTitles = [titles count];
        NSUInteger numberOfSections = [self numberOfSections];
        if (numberOfTitles && numberOfTitles != numberOfSections) {
            NSLog(@"**WARNING**: Number of section index titles returned does not match the number of sections (%u vs %u)", numberOfTitles, numberOfSections);
        }
        _indexListView.sectionIndexTitles = titles;
    }
}
@end
