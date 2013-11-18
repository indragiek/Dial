//
//  DALSectionIndexCollectionView.h
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-29.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DALSectionIndexListView.h"

extern CGFloat const DALSectionIndexListViewWidth;

@protocol DALSectionIndexCollectionViewDataSource <UICollectionViewDataSource>
@optional
- (NSArray *)sectionIndexTitlesForCollectionView:(UICollectionView *)collectionView;
@end

@protocol DALSectionIndexCollectionViewDelegate <UICollectionViewDelegate>
@optional
- (void)collectionView:(UICollectionView *)collectionView tappedSectionIndexTitle:(id)title;
@end

@interface DALSectionIndexCollectionView : UICollectionView
@property (nonatomic, strong, readonly) DALSectionIndexListView *indexListView;
@property (nonatomic, assign) id<DALSectionIndexCollectionViewDataSource> dataSource;
@property (nonatomic, assign) id<DALSectionIndexCollectionViewDelegate> delegate;
@end


