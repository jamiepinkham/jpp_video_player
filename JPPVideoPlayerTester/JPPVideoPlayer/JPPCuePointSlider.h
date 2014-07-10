//
//  JPPCuePointSlider.h
//  JPPVideoPlayerTester
//
//  Created by Jamie Pinkham on 8/28/13.
//  Copyright (c) 2013 Jamie Pinkham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPPPlaybackControl.h"

@class JPPPlaybackControlsBar;

@protocol JPPCueViewContainer
@property (nonatomic, strong) NSDictionary *cueViews;  // Keys are NSNumbers wrapping a float, values are UIViews

- (void)setCueView:(UIView *)cueView forValue:(NSNumber *)value;  // Value should represent a float time, in seconds, for the cue point
- (void)removeCueViewForvalue:(NSNumber *)value;

@end

@protocol JPPCuePointSliderDelegate;

@interface JPPCuePointSlider : UISlider <JPPCueViewContainer, JPPPlaybackControl>
@property (nonatomic, assign) CGSize thumbShadow;
@property (nonatomic, weak) id <JPPCuePointSliderDelegate> delegate;
@property (nonatomic, weak) JPPVideoPlayerController *avPlayerController;
@property (nonatomic, assign) CGFloat toolbarWidth;

// Subclasses can override this method to adjust where the view is displayed
- (CGRect)rectForCueView:(UIView *)view bounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value;

@end

@protocol JPPCuePointSliderDelegate <NSObject>

- (void)slider:(JPPCuePointSlider *)slider didChangeValue:(float)value;
- (void)sliderTrackingDidCancel:(JPPCuePointSlider *)slider;
- (void)sliderTrackingDidEnd:(JPPCuePointSlider *)slider;
- (void)sliderTrackingDidBegin:(JPPCuePointSlider *)slider;

@end
