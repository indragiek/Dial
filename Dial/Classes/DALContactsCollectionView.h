//
//  DALContactsCollectionView.h
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-29.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "DALSectionIndexCollectionView.h"

@class DALContactsCollectionView;
@protocol DALContactsCollectionViewDelegate <DALSectionIndexCollectionViewDelegate>
@optional
- (void)collectionView:(DALContactsCollectionView *)collectionView longPressOnCellAtIndexPath:(NSIndexPath *)indexPath atPoint:(CGPoint)point;
@end

@interface DALContactsCollectionView : DALSectionIndexCollectionView
@property (nonatomic, assign) id<DALContactsCollectionViewDelegate> delegate;
@end
