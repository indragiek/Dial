//
//  DALOverlayViewController.m
//  Dial
//
//  Created by Indragie Karunaratne on 2012-12-02.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "DALOverlayViewController.h"
#import "DALCircularMenu.h"

#import "CoreGraphics+DALAdditions.h"

#define ROTATE_BUFFER M_PI / 12.f

static NSString* const DALOverlayMenuEditButtonImageName = @"button-edit";
static NSString* const DALOverlayMenuFaceTimeButtonImageName = @"button-facetime";
static NSString* const DALOverlayMenuMessageButtonImageName = @"button-message";
static NSString* const DALOverlayMenuStarButtonImageName = @"button-star";

@interface DALOverlayViewController ()
@property (nonatomic, strong) DALLongPressOverlayView *backgroundView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) DALCircularMenu *circularMenu;
@end

@implementation DALOverlayViewController {
    UIImage *_cellImage;
    CGPoint _cellOrigin;
}

- (id)initWithCellImage:(UIImage *)image
             cellOrigin:(CGPoint)origin
{
    if ((self = [super init])) {
        _cellImage = image;
        _cellOrigin = origin;
    }
    return self;
}

- (void)expandMenu
{
    [self.view addSubview:self.backgroundView];
    [self.view addSubview:self.circularMenu];
    [self.view addSubview:self.imageView];
    [UIView animateWithDuration:_circularMenu.animationDuration animations:^{
        self.backgroundView.alpha = 1.f;
    }];
    [self.circularMenu expandWithCompletion:nil];
}

- (void)closeMenu
{
    if (self.circularMenu.animating) { return; }
    [self.circularMenu closeWithCompletion:^(DALCircularMenu *menu) {
        [self.circularMenu removeFromSuperview];
        [self.imageView removeFromSuperview];
        if (self.closeCompletionBlock)
            self.closeCompletionBlock(self);
    }];
    [UIView animateWithDuration:self.circularMenu.animationDuration animations:^{
        self.backgroundView.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self.backgroundView removeFromSuperview];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.frame = [[UIScreen mainScreen] bounds];
    self.view.opaque = NO;
    self.view.backgroundColor = [UIColor clearColor];
    CGPoint origin = [self.view convertPoint:_cellOrigin fromView:nil];
    
    DALLongPressOverlayView *backgroundView = [[DALLongPressOverlayView alloc] initWithFrame:self.view.bounds];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    backgroundView.delegate = self;
    backgroundView.alpha = 0.f;
    self.backgroundView = backgroundView;
    
    CGSize imageSize = _cellImage.size;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, imageSize.width, imageSize.height)];
    imageView.center = origin;
    imageView.image = _cellImage;
    self.imageView = imageView;
    
    UIButton *facetime = [self _menuButtonForImageName:DALOverlayMenuFaceTimeButtonImageName];
    UIButton *message = [self _menuButtonForImageName:DALOverlayMenuMessageButtonImageName];
    UIButton *star = [self _menuButtonForImageName:DALOverlayMenuStarButtonImageName];
    UIButton *edit = [self _menuButtonForImageName:DALOverlayMenuEditButtonImageName];
    NSArray *items = @[facetime, message, star, edit];
    
    DALCircularMenu *circularMenu = [[DALCircularMenu alloc] initWithFrame:self.view.bounds];
    circularMenu.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    circularMenu.userInteractionEnabled = NO;
    circularMenu.animationOrigin = origin;
    
    CGRect bounds = self.view.bounds;
    BOOL reverseItems = NO;
    BOOL bottom = origin.y >= CGRectGetMidY(bounds);
    BOOL right = origin.x >= CGRectGetMidX(bounds);
    CGFloat r = circularMenu.destinationRadius;
    CGFloat a = CGRectGetWidth(facetime.frame) / 2.f;
    if (!bottom) {
        origin.y -= 20.f;
    }
    CGFloat h = bottom ? (CGRectGetMaxY(bounds) - origin.y) : origin.y;
    CGFloat w = right ? (CGRectGetMaxX(bounds) - origin.x) : origin.x;
    CGFloat ma /* menu angle */, ra /* rotation angle */ = 0.f;
    if (origin.x - r < CGRectGetMinX(bounds)) {
        if (h >= (r + a)) {
            ma = M_PI - (ROTATE_BUFFER * 4.f);
            ra = (ROTATE_BUFFER * 2.f);
        } else {
            if (bottom) {
                ma = M_PI_2 + asin((w-a)/r) + asin((h-a)/r) - (ROTATE_BUFFER * 2.f);
                ra = -asin((w-a)/r) + ROTATE_BUFFER;
            } else {
                origin.y -= 20.f;
                ma = (3.f * M_PI / 2.f) - acos((w-a)/r) - acos((h-a)/r) - (ROTATE_BUFFER * 2.f);
                ra = acos((h-a)/r) + ROTATE_BUFFER;
            }
        }
    } else if (origin.x + r > CGRectGetMaxX(bounds)) {
        if (h >= (r + a)) {
            ma = -M_PI + (ROTATE_BUFFER * 4.f);
            ra = -(ROTATE_BUFFER * 2.f);
        } else {
            if (bottom) {
                ma = -M_PI_2 - asin((w-a)/r) - asin((h-a)/r) + (ROTATE_BUFFER * 2.f);
                ra = asin((w-a)/r) - ROTATE_BUFFER;
            } else {
                ma = acos((w-a)/r) + acos((h-a)/r) - (3.f * M_PI / 2.f)+ (ROTATE_BUFFER * 2.f);
                ra = -acos((h-a)/r) - ROTATE_BUFFER;
            }
        }
    } else {
        ma = 3.f * M_PI / 4.f;
        ra = -3.f * M_PI / 8.f;
        if (!bottom && h < r) {
            ra -= M_PI;
            reverseItems = YES;
        }
    }
    circularMenu.menuAngle = ma;
    circularMenu.itemRotationAngle = ra;
    if (reverseItems) {
        circularMenu.menuItems = @[edit, star, message, facetime];
    } else {
        circularMenu.menuItems = @[facetime, message, star, edit];
    }
    self.circularMenu = circularMenu;
}

#pragma mark - DALLongPressOverlayViewDelegate

- (void)overlayViewTapped:(DALLongPressOverlayView *)overlayView
{
    [self closeMenu];
}

#pragma mark - Private

- (UIButton *)_menuButtonForImageName:(NSString *)name
{
    UIImage *image = [UIImage imageNamed:name];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.f, 0.f, image.size.width, image.size.height);
    [button setImage:image forState:UIControlStateNormal];
    return button;
}


@end
