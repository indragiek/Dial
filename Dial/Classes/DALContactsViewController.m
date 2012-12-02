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
#import "DALCircularMenu.h"

#import "DALABAddressBook.h"
#import "DALABPerson.h"
#import "DALImageCache.h"

#import "UIImage+ProportionalFill.h"
#import "UIView+DALAdditions.h"
#import "UIImage+DALAdditions.h"

#import <QuartzCore/QuartzCore.h>

static NSString* const DALContactsCellIdentifier = @"DALContactsCell";
static NSString* const DALContactsCellStarImageName = @"star";
static NSString* const DALContactsCellPlaceholderImageName = @"placeholder";
static CGFloat const DALContactsAnimationDuration = 0.25f;

@interface DALContactsViewController ()
@property (nonatomic, strong) NSArray *people;
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
        self.overlayBackgroundView = [[DALLongPressOverlayView alloc] initWithFrame:[container bounds]];
        self.overlayBackgroundView.alpha = 0.f;
        self.overlayBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.overlayBackgroundView.delegate = self;
        UIView *imageContainer = cell.imageContainerView;
        UIImage *contactImage = [imageContainer.UIImage imageCroppedToEllipse];
        CGRect frame = [imageContainer convertRect:[imageContainer bounds] toView:container];
        self.overlayImageView = [[UIImageView alloc] initWithFrame:frame];
        self.overlayImageView.image = contactImage;
        NSMutableArray *menuItems = [NSMutableArray arrayWithCapacity:4];
        for (NSUInteger i = 0; i < 4; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0, 0, 44, 44);
            [button setImage:[UIImage imageNamed:@"menu-button"] forState:UIControlStateNormal];
            [menuItems addObject:button];
        }
        self.contactMenu = [[DALCircularMenu alloc] initWithFrame:[container bounds]];
        self.contactMenu.animationOrigin = _overlayImageView.center;
        self.contactMenu.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.contactMenu.menuItems = menuItems;
        self.contactMenu.userInteractionEnabled = NO;
        [container addSubview:_overlayBackgroundView];
        [container addSubview:_contactMenu];
        [container addSubview:_overlayImageView];
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
@end
