//
//  JPPPlayPauseButton.h
//  JPPVideoPlayerTester
//
//  Created by Jamie Pinkham on 9/6/13.
//  Copyright (c) 2013 Jamie Pinkham. All rights reserved.
//

#import "JPPBasePlaybackControl.h"

@interface JPPPlayPauseControl : JPPBasePlaybackControl <UIAppearance>

- (void)setPlayImage:(UIImage *)image forState:(UIControlState)controlState UI_APPEARANCE_SELECTOR;
- (void)setPauseImage:(UIImage *)image forState:(UIControlState)controlState UI_APPEARANCE_SELECTOR;

@end
