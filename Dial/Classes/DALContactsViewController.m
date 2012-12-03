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
#import "DALCircularMenu.h"

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

static NSString* const DALContactsCellEditButtonImageName = @"button-edit";
static NSString* const DALContactsCellFaceTimeButtonImageName = @"button-facetime";
static NSString* const DALContactsCellMessageButtonImageName = @"button-message";
static NSString* const DALContactsCellStarButtonImageName = @"button-star";
static NSString* const DALContactsCellStarImageName = @"star";
static NSString* const DALContactsCellPlaceholderImageName = @"placeholder";

static NSString* const DALContactsWildcardSectionName = @"#";

@interface DALContactsViewController ()
@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) DALLongPressOverlayView *overlayBackgroundView;
@property (nonatomic, strong) UIImageView *overlayImageView;
@property (nonatomic, strong) DALCircularMenu *contactMenu;
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
    void (^buildSections)() = ^(){
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
    };
    if (addressBook.authorizationStatus != kABAuthorizationStatusAuthorized) {
        [addressBook requestAuthorizationWithCompletionHandler:^(DALABAddressBook *addressBook, BOOL granted, NSError *error) {
            if (granted)
                buildSections();
        }];
    } else {
        buildSections();
    }
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
        self.overlayBackgroundView = [self _configuredOverlayView];
        self.overlayBackgroundView.alpha = 0.f;
        self.overlayImageView = [self _configuredOverlayImageViewWithCell:cell];
        self.contactMenu = [self _configuredMenuWithOrigin:self.overlayImageView.center];
        [container addSubview:self.overlayBackgroundView];
        [container addSubview:self.contactMenu];
        [container addSubview:self.overlayImageView];
        [UIView animateWithDuration:self.contactMenu.animationDuration animations:^{
            self.overlayBackgroundView.alpha = 1.f;
        }];
        [self.contactMenu expandWithCompletion:nil];
    }
}

#pragma mark - DALLongPressOverlayViewDelegate

- (void)overlayViewTapped:(DALLongPressOverlayView *)overlayView
{
    if (self.contactMenu.animating) { return; }
    [self.contactMenu closeWithCompletion:^(DALCircularMenu *menu) {
        [self.contactMenu removeFromSuperview];
        [self.overlayBackgroundView removeFromSuperview];
        self.overlayBackgroundView = nil;
        [self.overlayImageView removeFromSuperview];
        self.overlayImageView = nil;
        self.contactMenu = nil;
    }];
    [UIView animateWithDuration:self.contactMenu.animationDuration animations:^{
        self.overlayBackgroundView.alpha = 0.f;
    }];
}

#pragma mark - Private

- (DALABPerson *)_personAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self.sections[indexPath.section] contacts] objectAtIndex:indexPath.row];
}

- (UIButton *)_menuButtonForImageName:(NSString *)name
{
    UIImage *image = [UIImage imageNamed:name];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.f, 0.f, image.size.width, image.size.height);
    [button setImage:image forState:UIControlStateNormal];
    return button;
}

- (DALLongPressOverlayView *)_configuredOverlayView
{
    UIView *container = [self.view superview];
    DALLongPressOverlayView *overlay = [[DALLongPressOverlayView alloc] initWithFrame:[container bounds]];
    overlay.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    overlay.delegate = self;
    return overlay;
}

- (UIImageView *)_configuredOverlayImageViewWithCell:(DALContactCollectionViewCell *)cell
{
    UIView *container = [self.view superview];
    UIView *imageContainer = cell.imageContainerView;
    UIImage *contactImage = [imageContainer.UIImage imageCroppedToEllipse];
    CGRect frame = [imageContainer convertRect:[imageContainer bounds] toView:container];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.image = contactImage;
    return imageView;
}

- (DALCircularMenu *)_configuredMenuWithOrigin:(CGPoint)origin
{
    UIView *container = [self.view superview];
    UIButton *facetime = [self _menuButtonForImageName:DALContactsCellFaceTimeButtonImageName];
    UIButton *message = [self _menuButtonForImageName:DALContactsCellMessageButtonImageName];
    UIButton *star = [self _menuButtonForImageName:DALContactsCellStarButtonImageName];
    UIButton *edit = [self _menuButtonForImageName:DALContactsCellEditButtonImageName];
    DALCircularMenu *menu = [[DALCircularMenu alloc] initWithFrame:[container bounds]];
    menu.animationOrigin = origin;
    CGFloat radius = menu.destinationRadius;
    if (origin.x - radius < 0.f) { // left
        menu.menuAngle = M_PI;
        menu.itemRotationAngle = M_PI/8.f;
    } else if (origin.x + radius > CGRectGetMaxX(container.bounds)) { // right
        menu.menuAngle = -M_PI;
        menu.itemRotationAngle = -M_PI/8.f;
    } else { // center
        menu.menuAngle = M_PI;
        menu.itemRotationAngle = -M_PI/2.65f;
    }
    menu.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    menu.menuItems = @[facetime, message, star, edit];
    menu.userInteractionEnabled = NO;
    return menu;
}
@end
