//
//  DALOverlayViewController.m
//  Dial
//
//  Created by Indragie Karunaratne on 2012-12-02.
//  Copyright (c) 2012 Reactive Development. All rights reserved.
//

#import "DALOverlayViewController.h"
#import "DALCircularMenu.h"

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
    
    DALCircularMenu *circularMenu = [[DALCircularMenu alloc] initWithFrame:self.view.bounds];
    circularMenu.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    circularMenu.userInteractionEnabled = NO;
    circularMenu.animationOrigin = origin;
    
    CGFloat r = circularMenu.destinationRadius + CGRectGetWidth(facetime.frame) / 2.f;
    BOOL lowerHalf = origin.y >= CGRectGetMidY(self.view.bounds);
    BOOL reverseItemOrder = NO;
    CGFloat h = lowerHalf ? (CGRectGetMaxY(self.view.bounds) - origin.y) : origin.y;
    if (origin.x - r < 0.f) { // left
        if (h >= r) {
            circularMenu.menuAngle = M_PI;
            circularMenu.itemRotationAngle = M_PI/8.f;
        } else {
            if (lowerHalf) {
                circularMenu.menuAngle = M_PI/2.f + asin(h/r);
                circularMenu.itemRotationAngle = 0.f;
            } else {
                circularMenu.menuAngle = M_PI/2.f + atan(h/r);
                circularMenu.itemRotationAngle = M_PI/4.f + acos(h/r);
            }
        }
    } else if (origin.x + r > CGRectGetMaxX(self.view.bounds)) { // right
        if (h >= r) {
            circularMenu.menuAngle = -M_PI;
            circularMenu.itemRotationAngle = -M_PI/8.f;
        } else {
            if (lowerHalf) {
                
            } else {
                circularMenu.menuAngle = M_PI/2.f + atan(h/r);
                circularMenu.itemRotationAngle = -(M_PI - 2*acos(h/r));
            }
        }
    } else { // center
        circularMenu.menuAngle = M_PI;
        circularMenu.itemRotationAngle = -M_PI / 2.65f;
        if (!lowerHalf && h < r) {
            circularMenu.itemRotationAngle -= M_PI;
            reverseItemOrder = YES;
        }
    }
    if (reverseItemOrder) {
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
