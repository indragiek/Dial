//
//  DALSectionIndexListView.h
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-29.
//  Copyright (c) 2012 Reactive Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DALSectionIndexCollectionView;
@interface DALSectionIndexListView : UIView
@property (nonatomic, weak) DALSectionIndexCollectionView *collectionView;
@property (nonatomic, strong) NSArray *sectionIndexTitles;

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *highlightedTextColor;
@property (nonatomic, strong) NSShadow *textShadow;

@property (nonatomic, assign, getter=isHighlighted, readonly) BOOL highlighted;
@end
