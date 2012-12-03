//
//  DALContactsViewController.m
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-26.
//  Copyright (c) 2012 Reactive Development. All rights reserved.
//

#import "DALContactsViewController.h"
#import "DALContactCollectionViewCell.h"
#import "DALContactsCollectionView.h"
#import "DALContactSectionHeaderView.h"
#import "DALOverlayViewController.h"

#import "DALABAddressBook.h"
#import "DALABPerson.h"
#import "DALImageCache.h"
#import "DALContactSectionData.h"

#import "UIImage+ProportionalFill.h"
#import "UIView+DALAdditions.h"
#import "UIImage+DALAdditions.h"

#import <QuartzCore/QuartzCore.h>

static NSString* const DALContactsCellIdentifier = @"DALContactsCell";
static NSString* const DALHeaderViewIdentifier = @"DALSectionHeaderView";

static NSString* const DALContactsCellStarImageName = @"star";
static NSString* const DALContactsCellPlaceholderImageName = @"placeholder";

@interface DALContactsViewController ()
@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) DALOverlayViewController *overlayViewController;
@end

@implementation DALContactsViewController {
    dispatch_queue_t _imageQueue;
    DALImageCache *_imageCache;
}
#pragma mark - UIViewController

- (id)init
{
    if ((self = [super init])) {
        _imageQueue = dispatch_queue_create("com.reactive.Dial.imageQueue", DISPATCH_QUEUE_SERIAL);
        _imageCache = [DALImageCache new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([DALContactCollectionViewCell class]) bundle:nil];
    UINib *headerNib = [UINib nibWithNibName:NSStringFromClass([DALContactSectionHeaderView class]) bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:DALContactsCellIdentifier];
    [self.collectionView registerNib:headerNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:DALHeaderViewIdentifier];
    
    DALABAddressBook *addressBook = [DALABAddressBook addressBook];
    if (addressBook.authorizationStatus != kABAuthorizationStatusAuthorized) {
        [addressBook requestAuthorizationWithCompletionHandler:^(DALABAddressBook *addressBook, BOOL granted, NSError *error) {
            if (granted) [self _buildSections];
        }];
    } else {
        [self _buildSections];
    }
    [addressBook registerForChangeNotificationsWithHandler:^(NSDictionary *info) {
        [self _buildSections];
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.sections count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[self.sections[section] contacts] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DALContactCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DALContactsCellIdentifier forIndexPath:indexPath];
    DALABPerson *person = [self _personAtIndexPath:indexPath];
    cell.firstNameLabel.text = person.firstName;
    cell.lastNameLabel.text = person.lastName;
    void (^setImageViewImage)(UIImage*) = ^(UIImage *image){
        DALContactCollectionViewCell *aCell = (DALContactCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        aCell.imageView.image = image;
    };
    [_imageCache fetchImageForKey:person.compositeName completionHandler:^(UIImage *image) {
        if (image) {
            setImageViewImage(image);
        } else {
            NSData *imageData = person.imageData;
            if (imageData) {
                CGFloat imageWidth = CGRectGetWidth(cell.imageView.bounds);
                dispatch_async(_imageQueue, ^{
                    @autoreleasepool {
                        UIImage *image = [[UIImage alloc] initWithData:imageData];
                        UIImage *processed = [image imageCroppedToFitSize:CGSizeMake(imageWidth, imageWidth)];
                        [_imageCache setCachedImage:processed forKey:person.compositeName];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            setImageViewImage(processed);
                        });
                    }
                });
            } else {
                cell.imageView.image = [UIImage imageNamed:DALContactsCellPlaceholderImageName];
            }
        }
    }];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    DALContactCollectionViewCell *contactCell = (DALContactCollectionViewCell *)cell;
    contactCell.firstNameLabel.text = nil;
    contactCell.lastNameLabel.text = nil;
    contactCell.imageView.image = nil;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        DALContactSectionHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:DALHeaderViewIdentifier forIndexPath:indexPath];
        header.headerLabel.text = [self.sections[indexPath.section] title];
        return header;
    }
    return nil;
}

- (NSArray *)sectionIndexTitlesForCollectionView:(UICollectionView *)collectionView
{
    NSMutableArray *titles = [NSMutableArray array];
    [titles addObject:[UIImage imageNamed:DALContactsCellStarImageName]];
    [titles addObjectsFromArray:[[UILocalizedIndexedCollation currentCollation] sectionIndexTitles]];
    return titles;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(DALContactsCollectionView *)collectionView longPressOnCellAtIndexPath:(NSIndexPath *)indexPath
{
    DALContactCollectionViewCell *cell = (DALContactCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell) {
        UIView *container = [self.view superview];
        UIView *imageContainer = cell.imageContainerView;
        UIImage *contactImage = [imageContainer.UIImage imageCroppedToEllipse];
        CGPoint origin = [imageContainer.superview convertPoint:imageContainer.center toView:nil];
        DALOverlayViewController *overlayViewController = [[DALOverlayViewController alloc] initWithCellImage:contactImage cellOrigin:origin];
        overlayViewController.view.frame = container.bounds;
        overlayViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [container addSubview:overlayViewController.view];
        [overlayViewController setCloseCompletionBlock:^(DALOverlayViewController *vc) {
            [self.overlayViewController.view removeFromSuperview];
            self.overlayViewController = nil;
        }];
        self.overlayViewController = overlayViewController;
        [self.overlayViewController expandMenu];
    }
}

- (void)collectionView:(UICollectionView *)collectionView tappedSectionIndexTitle:(id)title
{
    [self.sections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([[obj indexTitle] isEqual:title]) {
            UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForSupplementaryElementOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForRow:NSNotFound inSection:idx]];
            CGRect itemFrame = attributes.frame;
            itemFrame.size.height = CGRectGetHeight(self.collectionView.frame);
            [self.collectionView scrollRectToVisible:itemFrame animated:NO];
            *stop = YES;
        }
    }];
}

#pragma mark - Private Data Model Methods

- (DALABPerson *)_personAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self.sections[indexPath.section] contacts] objectAtIndex:indexPath.row];
}

- (void)_buildSections
{
    DALABAddressBook *addressBook = [DALABAddressBook addressBook];
    NSArray *people = [addressBook allPeople];
    NSMutableDictionary *sectionDict = [NSMutableDictionary dictionary];
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    [people enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSInteger section = [collation sectionForObject:obj collationStringSelector:@selector(firstName)];
        NSMutableArray *contacts = sectionDict[@(section)] ?: [NSMutableArray new];
        [contacts addObject:obj];
        sectionDict[@(section)] = contacts;
    }];
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:[sectionDict count]];
    NSArray *sortedKeys = [[sectionDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
    [sortedKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMutableArray *contacts = sectionDict[obj];
        DALContactSectionData *data = [DALContactSectionData new];
        data.contacts = contacts;
        NSInteger section = [obj integerValue];
        data.title = [collation.sectionTitles objectAtIndex:section];
        data.indexTitle = [collation.sectionIndexTitles objectAtIndex:section];
        [sections addObject:data];
    }];
    self.sections = sections;
    [self.collectionView reloadData];
}
@end
