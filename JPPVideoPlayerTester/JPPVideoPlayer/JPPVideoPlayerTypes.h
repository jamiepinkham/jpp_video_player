//
//  JPPVideoPlayerTypes.h
//  JPPVideoPlayerTester
//
//  Created by Jamie Pinkham on 9/5/13.
//  Copyright (c) 2013 Bottle Rocket. All rights reserved.
//

#ifndef JPPVideoPlayerTester_JPPVideoPlayerTypes_h
#define JPPVideoPlayerTester_JPPVideoPlayerTypes_h

typedef NS_ENUM(NSInteger, JPPVideoScalingMode)
{
	JPPVideoScalingModeNone,       // No scaling
    JPPVideoScalingModeAspectFit,  // Uniform scale until one dimension fits
    JPPVideoScalingModeAspectFill, // Uniform scale until the movie fills the visible bounds. One dimension may have clipped contents
    JPPVideoScalingModeFill        // Non-uniform scale. Both render dimensions will exactly match the visible bounds
};

typedef NS_ENUM(NSInteger, JPPVideoLoadState)
{
	JPPVideoLoadStateUnknown,
	JPPVideoLoadStatePlayable,
	JPPVideoLoadStatePlaythroughOK,
	JPPVideoLoadStateStalled,
};

typedef NS_ENUM(NSInteger, JPPVideoPlaybackState)
{
	JPPVideoPlaybackStateStopped,
	JPPVideoPlaybackStatePlaying,
	JPPVideoPlaybackStatePaused,
	JPPVideoPlaybackStateInterrupted,
	JPPVideoPlaybackStateSeekingForward,
	JPPVideoPlaybackStateSeekingBackward,
};

typedef NS_ENUM(NSInteger, JPPVideoPlayerControllerEvent)
{
	JPPVideoPlayerControllerEventPlaybackDidChange,
	JPPVideoPlayerControllerEventWillEnterFullscreen,
	JPPVideoPlayerControllerEventDidEnterFullscreen,
	JPPVideoPlayerControllerEventWillExitFullscreen,
	JPPVideoPlayerControllerEventDidExitFullscreen,
	JPPVideoPlayerControllerEventScalingModeChanged,
	JPPVideoPlayerControllerEventPlaybackTimeChanged,
	JPPVideoPlayerControllerEventDurationAvailable,
	JPPVideoPlayerControllerEventNaturalSizeAvailable,
	JPPVideoPlayerControllerEventLoadStateChanged,
	JPPVideoPlayerControllerEventNowPlayingChanged,
	JPPVideoPlayerControllerEventRateChanged,
	JPPVideoPlayerControllerEventApplication,  // Custom events should be defined starting with this enumeration
};

typedef NS_ENUM(NSInteger, JPPVideoPlayerClosedCaptioningMode)
{
	JPPVideoPlayerClosedCaptioningDefault,  // User's accessibility settings are respected.
	JPPVideoPlayerClosedCaptioningOff,
	JPPVideoPlayerClosedCaptioningOn,
};

typedef NS_ENUM(NSInteger, JPPVideoFinishReason) {
	JPPVideoFinishReasonNotFinished,
    JPPVideoFinishReasonPlaybackEnded,
    JPPVideoFinishReasonPlaybackError,
    JPPVideoFinishReasonUserExited
};

typedef void(^JPPVideoPlayerControllerClosedCaptionToggleCallback)(BOOL isClosedCaptioningAvailable);

typedef NS_OPTIONS(NSInteger, JPPVideoPlayerControllerEventMask){
	JPPVideoPlayerControllerEventMaskNone = 0xff,
	JPPVideoPlayerControllerEventMaskPlaybackDidChange = (1 << JPPVideoPlayerControllerEventPlaybackDidChange),
	JPPVideoPlayerControllerEventMaskWillEnterFullscreen = (1 << JPPVideoPlayerControllerEventWillEnterFullscreen),
	JPPVideoPlayerControllerEventMaskDidEnterFullscreen = (1 << JPPVideoPlayerControllerEventDidEnterFullscreen),
	JPPVideoPlayerControllerEventMaskWillExitFullscreen = (1 << JPPVideoPlayerControllerEventWillExitFullscreen),
	JPPVideoPlayerControllerEventMaskDidExitFullscreen = (1 << JPPVideoPlayerControllerEventDidExitFullscreen),
	JPPVideoPlayerControllerEventMaskScalingModeChanged = (1 << JPPVideoPlayerControllerEventScalingModeChanged),
	JPPVideoPlayerControllerEventMaskPlaybackTimeChanged = (1 << JPPVideoPlayerControllerEventPlaybackTimeChanged),
	JPPVideoPlayerControllerEventMaskDurationAvailable = (1 << JPPVideoPlayerControllerEventDurationAvailable),
	JPPVideoPlayerControllerEventMaskNaturalSizeAvailable = (1 << JPPVideoPlayerControllerEventNaturalSizeAvailable),
	JPPVideoPlayerControllerEventMaskLoadStateChanged = (1 << JPPVideoPlayerControllerEventLoadStateChanged),
	JPPVideoPlayerControllerEventMaskNowPlayingChanged = (1 << JPPVideoPlayerControllerEventNowPlayingChanged),
	JPPvideoPlayerControllerEventMaskRateChanged = ( 1 << JPPVideoPlayerControllerEventRateChanged),
	JPPVideoPlayerControllerEventMaskApplication = (1 << JPPVideoPlayerControllerEventApplication),
};

#endif
