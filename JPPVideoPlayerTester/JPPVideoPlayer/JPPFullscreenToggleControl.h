//
//  JPPFullscreenToggleControl.h
//  JPPVideoPlayerTester
//
//  Created by Jamie Pinkham on 9/6/13.
//  Copyright (c) 2013 Bottle Rocket. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPPBasePlaybackControl.h"

@interface JPPFullscreenToggleControl : JPPBasePlaybackControl <UIAppearance>

- (void)setFullscreenImage:(UIImage *)image forState:(UIControlState)state UI_APPEARANCE_SELECTOR;
- (void)setInlineImage:(UIImage *)image forState:(UIControlState)state UI_APPEARANCE_SELECTOR;

@end
