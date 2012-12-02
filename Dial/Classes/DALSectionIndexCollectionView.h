//
//  DALSectionIndexCollectionView.h
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-29.
//  Copyright (c) 2012 Reactive Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DALSectionIndexListView.h"

extern CGFloat const DALSectionIndexListViewWidth;

@class DALSectionIndexCollectionView;
@protocol DALSectionIndexCollectionViewDataSource <UICollectionViewDataSource>
@optional
- (NSArray *)sectionIndexTitlesForCollectionView:(UICollectionView *)collectionView;
@end

@interface DALSectionIndexCollectionView : UICollectionView
@property (nonatomic, strong, readonly) DALSectionIndexListView *indexListView;
@property (nonatomic, assign) id<DALSectionIndexCollectionViewDataSource> dataSource;
@end


