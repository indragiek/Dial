//
//  DALOverlayViewController.h
//  Dial
//
//  Created by Indragie Karunaratne on 2012-12-02.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DALViewController.h"
#import "DALLongPressOverlayView.h"

@class DALOverlayViewController;
typedef void (^DALOverlayCompletionBlock)(DALOverlayViewController*);

@interface DALOverlayViewController : DALViewController <DALLongPressOverlayViewDelegate>
- (id)initWithCellImage:(UIImage *)image
             cellOrigin:(CGPoint)origin;

- (void)expandMenu;
- (void)closeMenu;
@property (nonatomic, copy) DALOverlayCompletionBlock closeCompletionBlock;
@end
