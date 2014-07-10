//
//  JPPClosedCaptioningControl.h
//  JPPVideoPlayerTester
//
//  Created by Jamie Pinkham on 9/10/13.
//  Copyright (c) 2013 Bottle Rocket. All rights reserved.
//

#import "JPPBasePlaybackControl.h"

@interface JPPClosedCaptioningControl : JPPBasePlaybackControl <UIAppearance>

- (void)setClosedCaptionImage:(UIImage *)image forState:(UIControlState)state UI_APPEARANCE_SELECTOR;

@end
