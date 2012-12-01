//
//  DALLongPressOverlayView.h
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-30.
//  Copyright (c) 2012 Reactive Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DALLongPressOverlayView;
@protocol DALLongPressOverlayViewDelegate <NSObject>
@optional
- (void)overlayViewTapped:(DALLongPressOverlayView *)overlayView;
@end

@interface DALLongPressOverlayView : UIView
@property (nonatomic, assign) id<DALLongPressOverlayViewDelegate> delegate;
@end
