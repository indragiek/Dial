//
//  DALCircularMenu.h
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-30.
//  Copyright (c) 2012 Reactive Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DALCircularMenu;
@protocol DALCircularMenuDelegate <NSObject>
@optional
- (void)circularMenu:(DALCircularMenu *)menu selectedItemAtIndex:(NSUInteger)index;;
@end

@interface DALCircularMenu : UIView
/** Menu delegate */
@property (nonatomic, assign) id<DALCircularMenuDelegate> delegate;


@end
