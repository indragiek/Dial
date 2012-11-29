//
//  DALContactsViewController.m
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-26.
//  Copyright (c) 2012 Reactive Development. All rights reserved.
//

#import "DALContactsViewController.h"
#import "DALContactCollectionViewCell.h"

#import "DALABAddressBook.h"
#import "DALABPerson.h"
#import "DALImageCache.h"
#import "UIImage+DALAdditions.h"

static NSString* const DALContactsCellIdentifier = @"DALContactsCell";
static NSString* const DALContactsCellStarImageName = @"star";

@interface DALContactsViewController ()
@property (nonatomic, strong) NSArray *people;
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
                        UIImage *processed = [image circularImageCroppedToFaceWithWidth:imageWidth];
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
@end
