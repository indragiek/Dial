//
//  DALContactsViewController.m
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-26.
//  Copyright (c) 2012 Reactive Development. All rights reserved.
//

#import "DALContactsViewController.h"
#import "DALContactCollectionViewCell.h"

static NSString* const DALContactsBackgroundPatternImageName = @"bg";
static NSString* const DALContactsCellIdentifier = @"DALContactsCell";
static CGFloat const DALContactsLayoutMinimumLineSpacing = 21.f;
static CGFloat const DALContactsLayoutMinimumInteritemSpacing = 15.f;
static CGFloat const DALContactsLayoutItemWidth = 81.f;
static CGFloat const DALContactsLayoutItemHeight = 121.f;


@implementation DALContactsViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([DALContactCollectionViewCell class]) bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:DALContactsCellIdentifier];
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:DALContactsBackgroundPatternImageName]];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.minimumLineSpacing = DALContactsLayoutMinimumLineSpacing;
    layout.minimumInteritemSpacing = DALContactsLayoutMinimumInteritemSpacing;
    layout.itemSize = CGSizeMake(DALContactsLayoutItemWidth, DALContactsLayoutItemHeight);
    layout.sectionInset = UIEdgeInsetsMake(DALContactsLayoutMinimumLineSpacing, DALContactsLayoutMinimumInteritemSpacing, DALContactsLayoutMinimumLineSpacing, DALContactsLayoutMinimumInteritemSpacing);
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 12;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DALContactCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DALContactsCellIdentifier forIndexPath:indexPath];
    return cell;
}
@end
