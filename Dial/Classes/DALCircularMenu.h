//
//  DALCircularMenu.h
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-30.
//  Copyright (c) 2012 Reactive Development. All rights reserved.
//

#import <UIKit/UIKit.h>

/** Class for displaying a circular animating menu based on AwesomeMenu <https://github.com/levey/AwesomeMenu> */

@class DALCircularMenu;
@protocol DALCircularMenuDelegate <NSObject>
@optional
- (void)circularMenu:(DALCircularMenu *)menu selectedItemAtIndex:(NSUInteger)index;;
@end

typedef void (^DALCircularMenuCompletionBlock)(DALCircularMenu*);

@interface DALCircularMenu : UIView
/** Menu delegate */
@property (nonatomic, assign) id<DALCircularMenuDelegate> delegate;

/** The point at which the menu items originate from, in the local view's coordinate space. Default value is the view origin {0, 0} */
@property (nonatomic, assign) CGPoint animationOrigin;
/** The menu's angle in radians. (set to M_PI*2 for a circular menu, M_PI for a semicircle, etc.). Default is M_PI */
@property (nonatomic, assign) CGFloat menuAngle;
/** The angle of rotation for each menu item. Default is 0 */
@property (nonatomic, assign) CGFloat itemRotationAngle;
/** The radius of the end point of each menu item relative to the animationOrigin. Default value is 100 */
@property (nonatomic, assign) CGFloat destinationRadius;

/** The ratio of the stretch point relative to the destinationRadius. The stretch point is the point in the bounce animation where the menu item is farthest from the animationOrigin (past the endRadius). Default value is 1.2.
 */
@property (nonatomic, assign) CGFloat stretchRatio;

/** The ration of the compression point relative to the destinationRadius. The compression point is the point in the bounce animation where the menu item is closest to the animationOrigin (before the endRadius). Default value is 0.9.
 */
@property (nonatomic, assign) CGFloat compressionRatio;

/** The time offset between the animations of each menu item. Default value is 0.03 */
@property (nonatomic, assign) CGFloat animationTimeOffset;
/** The duration of the expand and close menu animations. Default value is 0.5 */
@property (nonatomic, assign) CGFloat animationDuration;

/** The menu items, as an array of UIButtons */
@property (nonatomic, strong) NSArray *menuItems;

/** Whether the view is animating */
@property (nonatomic, readonly) BOOL animating;

/** Expand the menu */
- (void)expandWithCompletion:(DALCircularMenuCompletionBlock)completion;
/** Close the menu */
- (void)closeWithCompletion:(DALCircularMenuCompletionBlock)completion;
@end
