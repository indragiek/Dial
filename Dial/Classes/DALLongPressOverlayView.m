//
//  DALLongPressOverlayView.m
//  Dial
//
//  Created by Indragie Karunaratne on 2012-11-30.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "DALLongPressOverlayView.h"

@implementation DALLongPressOverlayView

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.opaque = NO;
        self.backgroundColor = [UIColor colorWithRed:0.929 green:0.933 blue:0.937 alpha:0.95f];
    }
    return self;
}

#pragma mark - Touch Events

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self.delegate respondsToSelector:@selector(overlayViewTapped:)]) {
        [self.delegate overlayViewTapped:self];
    }
}
@end
