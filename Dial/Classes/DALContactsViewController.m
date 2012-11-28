//
//  DALContactsViewController.m
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-26.
//  Copyright (c) 2012 Reactive Development. All rights reserved.
//

#import "DALContactsViewController.h"
#import "DALContactCollectionViewCell.h"

#import "TTUnifiedAddressBook.h"
#import "TTUnifiedCard.h"

static NSString* const DALContactsBackgroundPatternImageName = @"bg";
static NSString* const DALContactsCellIdentifier = @"DALContactsCell";
static CGFloat const DALContactsLayoutMinimumLineSpacing = 21.f;
static CGFloat const DALContactsLayoutMinimumInteritemSpacing = 15.f;
static CGFloat const DALContactsLayoutItemWidth = 81.f;
static CGFloat const DALContactsLayoutItemHeight = 121.f;

@interface DALContactsViewController ()
@property (nonatomic, strong) NSArray *cards;
@end

@implementation DALContactsViewController {
    TTUnifiedAddressBook *_addressBook;
}
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
    
    [TTUnifiedAddressBook accessAddressBookWithGranted:^(ABAddressBookRef book) {
        _addressBook = [[TTUnifiedAddressBook alloc] initWithAddressBook:book];
        [_addressBook updateAddressBookWithCompletion:^{
            self.cards = [_addressBook allCards];
            [self.collectionView reloadData];
        }];
    } denied:nil];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.cards count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DALContactCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DALContactsCellIdentifier forIndexPath:indexPath];
    TTUnifiedCard *card = [self.cards objectAtIndex:indexPath.row];
    [card setAddressBook:_addressBook.addressBook];
    cell.firstNameLabel.text = [card stringForProperty:kABPersonFirstNameProperty];
    cell.lastNameLabel.text = [card stringForProperty:kABPersonLastNameProperty];
    return cell;
}
@end
