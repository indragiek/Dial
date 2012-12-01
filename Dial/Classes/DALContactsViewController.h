//
//  DALContactsViewController.h
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-26.
//  Copyright (c) 2012 Reactive Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DALViewController.h"

@protocol DALLongPressOverlayViewDelegate;
@interface DALContactsViewController : DALViewController <DALLongPressOverlayViewDelegate>
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@end
