//
//  JPPAVPlayerController.h
//  JPPVideoPlayerTester
//
//  Created by Jamie Pinkham on 8/15/13.
//  Copyright (c) 2013 Bottle Rocket. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import "JPPVideoPlayerTypes.h"

@class JPPVideoPlayerController;

@protocol JPPVideoPlayerControllerDelegate <NSObject>

@optional
- (void)avPlayerControllerLoadStateDidChange:(JPPVideoPlayerController *)avPlayerController;
- (void)avPlayerControllerPlayStateDidChange:(JPPVideoPlayerController *)avPlayerController;
- (void)avPlayerController:(JPPVideoPlayerController *)avPlayerController didUpdateItemDuration:(CMTime)duration;
- (void)avPlayerController:(JPPVideoPlayerController *)avPlayerController didUpdateItemNatualSize:(CGSize)size;
- (void)avPlayerController:(JPPVideoPlayerController *)avPlayerController didUpdateCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime;
- (void)avPlayerController:(JPPVideoPlayerController *)avPlayerController rateDidChange:(CGFloat)currentRate;

- (void)avPlayerController:(JPPVideoPlayerController *)avPlayerController eventOccurred:(JPPVideoPlayerControllerEvent)event;
- (void)avPlayerController:(JPPVideoPlayerController *)avPlayerController didChangeTracks:(AVPlayerItem *)playerItem;
- (void)avPlayerController:(JPPVideoPlayerController *)avPlayerController failedToLoadContentURL:(NSURL *)url;
																					  
@end


@interface JPPVideoPlayerController : NSObject <MPMediaPlayback>

- (instancetype)initWithDelegate:(id<JPPVideoPlayerControllerDelegate>)delegate;
//- (instancetype)initWithContentURL:(NSURL *)aURL delegate:(id<JPPAVPlayerControllerDelegate>)delegate;
@property (nonatomic, copy) NSURL *contentURL;
@property (nonatomic, weak) id<JPPVideoPlayerControllerDelegate> delegate;

@property (nonatomic, readonly) UIView *movieView;

@property (nonatomic, assign) BOOL shouldAutoplay;
- (BOOL)shouldPlayWhenPossible;

@property (nonatomic, getter = isFullscreen) BOOL fullscreen;
-(void)setFullscreen:(BOOL)fullscreen animated:(BOOL)animated;

@property (nonatomic, assign) JPPVideoScalingMode scalingMode;

// Time observation.  Times should be an array of NSValue objects wrapping CMTime.  This method could be used to add a boundary observer for ad times.
// These will be automatically cleaned up on on dealloc - as long as no retain cycles are created in the passed block.  Clients who wish to
// unsubscribe from the boundary observations early may retain the object returned by addBoundaryTimeObserverForTimes:queue:usingBlock: and use it
// as the parameter fro removeTimeObserver:
- (id)addBoundaryTimeObserverForTimes:(NSArray *)times queue:(dispatch_queue_t)queue usingBlock:(void (^)(void))block;
- (void)removeTimeObserver:(id)timeObserver;
// Returns the current playback state of the movie player.
@property(nonatomic, readonly) JPPVideoPlaybackState playbackState;

// Returns the network load state of the player.
@property(nonatomic, readonly) JPPVideoLoadState loadState;

// If playback has failed, this property will be non-nil
@property (nonatomic, readonly) NSError *error;


@end

@interface JPPVideoPlayerController (MediaPlayback)

@property (nonatomic, readonly) BOOL canSeekForward;
@property (nonatomic, readonly) BOOL canSeekBackward;

// The duration of the movie, -1.0 for a indefinite (ie, streaming) source, and 0.0 otherwise
@property (nonatomic, readonly) NSTimeInterval duration;

// The currently playable duration of the movie, for progressively downloaded network content.
@property (nonatomic, readonly) NSTimeInterval playableDuration;

// The natural size of the movie, or CGSizeZero if not known/applicable.
@property (nonatomic, readonly) CGSize naturalSize;

// Indicates whether the movie player allows AirPlay video playback. Defaults to YES.
@property (nonatomic) BOOL allowsAirPlay;

// Indicates whether the movie player is currently playing video via AirPlay.
@property (nonatomic, readonly, getter=isAirPlayVideoActive) BOOL airPlayVideoActive;

@property (nonatomic) JPPVideoPlayerClosedCaptioningMode closedCaptioningMode;

// Default nil, which will toggle the underlying AVPlayer's closedCaptioningEnabled flag.  If set, the callback will be called with
// a boolean indicating whether some external object should display closed captioning (for example, an clients may wish to use
// an external closed captioning file).
@property (nonatomic, copy) JPPVideoPlayerControllerClosedCaptionToggleCallback closedCaptioningCallback;

@property (nonatomic, readonly, getter = isClosedCaptioningAvailable) BOOL closedCaptioningAvailable;


- (void)playFromUserInteraction:(BOOL)userInteraction;
- (void)pauseFromUserInteraction:(BOOL)userInteraction stalledPause:(BOOL)stalledPause;

@end


@interface JPPVideoPlayerController (ClosedCaptioning)
- (BOOL)shouldEnableClosedCaptioningForMode:(JPPVideoPlayerClosedCaptioningMode)closedCaptioningMode;  // Returns the UIAccessibility value if mode is default
@end

extern NSString * const JPPVideoPlayerEventOccurredNotification;
extern NSString * const JPPVideoPlayerEventOccurredUserInfoKey;

extern NSString * const JPPVideoPlayerDurationAvailableNotification;
extern NSString * const JPPVideoPlayerNaturalSizeAvailableNotification;

extern NSString * const JPPVideoPlayerLoadStateDidChangeNotification;
extern NSString * const JPPVideoPlayerPlaybackStateDidChangeNotification;

extern NSString * const JPPVideoPlayerCurrentPlaybackTimeDidChangeNotification;

extern NSString * const JPPVideoPlayerNowPlayingDidChangeNotification;
extern NSString * const JPPVideoPlayerPlaybackDidFinishNotification;
extern NSString * const JPPVideoPlayerTimedMetadataNotification;

extern NSString * const JPPVideoPlayerRateChangedNotification;

extern NSString * const JPPVideoPlayerPlaybackDidFinishReasonUserInfoKey; //NSNumber (JPPVFinishReason)
extern NSString * const JPPVideoPlayerPlaybackStateUserInfoKey;
extern NSString * const JPPVideoPlayerTimedMetadataUserInfoKey;
extern NSString * const JPPVideoPlayerPlaybackUserInteractionInfoKey;

extern NSString * const JPPVideoPlayeRateChangedRateInfoKey;

extern NSString * const JPPVideoPlayerWillEnterFullscreenNotification;
extern NSString * const JPPVideoPlayerDidEnterFullscreenNotification;
extern NSString * const JPPVideoPlayerWillExitFullscreenNotification;
extern NSString * const JPPVideoPlayerDidExitFullscreenNotification;

extern NSString * const JPPVideoPlayerScalingModeDidChangeNotification;
