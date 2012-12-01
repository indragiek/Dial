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
#import "DALLongPressOverlayView.h"

#import "DALABAddressBook.h"
#import "DALABPerson.h"
#import "DALImageCache.h"

#import "UIImage+ProportionalFill.h"
#import "UIView+DALAdditions.h"

static NSString* const DALContactsCellIdentifier = @"DALContactsCell";
static NSString* const DALContactsCellStarImageName = @"star";
static CGFloat const DALContactsAnimationDuration = 0.25f;

@interface DALContactsViewController ()
@property (nonatomic, strong) NSArray *people;
@end

@implementation DALContactsViewController {
    dispatch_queue_t _imageQueue;
    DALImageCache *_imageCache;
    
    DALLongPressOverlayView *_overlayBackgroundView;
    UIImageView *_overlayImageView;
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
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:DALContactsCellIdentifier];
    
    DALABAddressBook *addressBook = [DALABAddressBook addressBook];
    void (^getPeople)() = ^(){
        self.people = [addressBook allPeople];
        [self.collectionView reloadData];
    };
    if (addressBook.authorizationStatus != kABAuthorizationStatusAuthorized) {
        [addressBook requestAuthorizationWithCompletionHandler:^(DALABAddressBook *addressBook, BOOL granted, NSError *error) {
            if (granted)
                getPeople();
        }];
    } else {
        getPeople();
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.people count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DALContactCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DALContactsCellIdentifier forIndexPath:indexPath];
    DALABPerson *person = [self.people objectAtIndex:indexPath.row];
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

- (NSArray *)sectionIndexTitlesForCollectionView:(UICollectionView *)collectionView
{
    return @[[UIImage imageNamed:DALContactsCellStarImageName], @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(DALContactsCollectionView *)collectionView longPressOnCellAtIndexPath:(NSIndexPath *)indexPath
{
    DALContactCollectionViewCell *cell = (DALContactCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell) {
        UIView *container = [self.view superview];
        _overlayBackgroundView = [[DALLongPressOverlayView alloc] initWithFrame:[container bounds]];
        _overlayBackgroundView.alpha = 0.f;
        _overlayBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _overlayBackgroundView.delegate = self;
        UIView *imageContainer = cell.imageContainerView;
        UIImage *contactImage = imageContainer.UIImage;
        CGRect frame = [imageContainer convertRect:[imageContainer bounds] toView:container];
        _overlayImageView = [[UIImageView alloc] initWithFrame:frame];
        _overlayImageView.image = contactImage;
        [container addSubview:_overlayBackgroundView];
        [container addSubview:_overlayImageView];
        [UIView animateWithDuration:DALContactsAnimationDuration animations:^{
            _overlayBackgroundView.alpha = 1.f;
        }];
    }
}

#pragma mark - DALLongPressOverlayViewDelegate

- (void)overlayViewTapped:(DALLongPressOverlayView *)overlayView
{
    [UIView animateWithDuration:DALContactsAnimationDuration animations:^{
        _overlayBackgroundView.alpha = 0.f;
    } completion:^(BOOL finished) {
        [_overlayBackgroundView removeFromSuperview];
        _overlayBackgroundView = nil;
        [_overlayImageView removeFromSuperview];
        _overlayImageView = nil;
    }];
}
@end
