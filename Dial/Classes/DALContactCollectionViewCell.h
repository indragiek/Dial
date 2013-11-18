//
//  DALContactCollectionViewCell.h
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-26.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DALContactCollectionViewCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet UILabel *firstNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *lastNameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIView *imageContainerView;
@end
