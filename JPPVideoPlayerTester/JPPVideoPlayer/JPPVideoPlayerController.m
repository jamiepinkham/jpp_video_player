//
//  JPPAVPlayerController.m
//  JPPVideoPlayerTester
//
//  Created by Jamie Pinkham on 8/15/13.
//  Copyright (c) 2013 Bottle Rocket. All rights reserved.
//

#import "JPPVideoPlayerController.h"
#import "JPPVideoPlayerView.h"

@interface JPPVideoPlayerController ()
{

	struct{
		unsigned loadStateChanged : 1;
		unsigned playStateChanged : 1;
		unsigned durationUpdated : 1;
		unsigned naturalSize : 1;
		unsigned didUpdateCurrentPlaybackTime : 1;
		unsigned eventOccured : 1;
		unsigned changeTracks : 1;
		unsigned urlFailed : 1;
		unsigned rateChanged : 1;
	}_delegateHas;
	
	BOOL _shouldPlayWhenPossible;
	id _periodicTimeObserver;
	
	// Fullscreen support
	NSMutableSet *_externalTimeObservers;
	
	JPPVideoPlayerClosedCaptioningMode _closedCaptioningMode;
	JPPVideoPlayerControllerClosedCaptionToggleCallback _closedCaptioningCallback;
}

@property (nonatomic, strong) JPPVideoPlayerView *playerView;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, readonly) AVPlayerItem *playerItem;
@property (nonatomic, readwrite) JPPVideoPlaybackState playbackState;
@property (nonatomic, readwrite) JPPVideoPlaybackState previousPlaybackState;
@property (nonatomic, readwrite) JPPVideoLoadState loadState;
@property (nonatomic, readwrite) JPPVideoFinishReason finishReason;
@property (nonatomic, readonly, getter = isSeeking) BOOL seeking;

@property (nonatomic, strong) UIView *preFullscreenSuperview;
@property (nonatomic, assign) NSInteger preFullscreenSubviewIndex;
@property (nonatomic, assign) CGRect preFullscreenFrame;
@property (nonatomic, assign) UIViewAutoresizing preFullscreenAutoresizing;
@property (nonatomic, assign) UIStatusBarStyle preFullscreenStatusBarStyle;
@property (nonatomic, assign) BOOL isPreFullscreenStatusBarHidden;
@end

static NSString * const kAVPlayerStatusKey = @"status";
static NSString * const kAVPlayerItemPlaybackKey = @"playbackLikelyToKeepUp";
static NSString * const kAVPlayerItemEmptyBufferKey = @"playbackBufferEmpty";
static NSString * const kAVPlayerCurrentItemKey = @"currentItem";
static NSString * const kAVPlayerTimedMetadataKey = @"currentItem.timedMetadata";
static NSString * const kAVPlayerItemTracksKey = @"tracks";
static NSString * const kAVPlayerErrorKey = @"error";
static NSString * const kAVPlayerRateKey = @"rate";

static void * JPPAVPlayerControllerPlaybackStatusContext = &JPPAVPlayerControllerPlaybackStatusContext;
static void * JPPAVPlayerControllerPlayerItemStatusContext = &JPPAVPlayerControllerPlayerItemStatusContext;
static void * JPPAVPlayerControllerPlayerCurrentItemContext = &JPPAVPlayerControllerPlayerCurrentItemContext;
static void * JPPAVPlayerControllerTimedMetadataContext = &JPPAVPlayerControllerTimedMetadataContext;
static void *JPPAVPlayerControllerRateContext = &JPPAVPlayerControllerRateContext;

NSString * const JPPVideoPlayerEventOccurredNotification = @"JPPVideoPlayerEventOccurredNotification";
NSString * const JPPVideoPlayerEventOccurredUserInfoKey = @"JPPVideoPlayerEventOccurredUserInfoKey";

NSString * const JPPVideoPlayerLoadStateDidChangeNotification = @"JPPVideoPlayerLoadStateDidChangeNotification";
NSString * const JPPVideoPlayerPlaybackStateDidChangeNotification = @"JPPVideoPlayerPlaybackStateDidChangeNotification";

NSString * const JPPVideoPlayerCurrentPlaybackTimeDidChangeNotification = @"JPPVideoPlayerCurrentPlaybackTimeDidChangeNotification";

NSString * const JPPVideoPlayerWillEnterFullscreenNotification = @"JPPVideoPlayerWillEnterFullscreenNotification";
NSString * const JPPVideoPlayerDidEnterFullscreenNotification = @"JPPVideoPlayerDidEnterFullscreenNotification";
NSString * const JPPVideoPlayerWillExitFullscreenNotification = @"JPPVideoPlayerWillExitFullscreenNotification";
NSString * const JPPVideoPlayerDidExitFullscreenNotification = @"JPPVideoPlayerDidExitFullscreenNotification";

NSString * const JPPVideoPlayerScalingModeDidChangeNotification = @"JPPVideoPlayerScalingModeDidChangeNotification";

NSString * const JPPVideoPlayerDurationAvailableNotification = @"JPPVideoPlayerDurationAvailableNotification";
NSString * const JPPVideoPlayerNaturalSizeAvailableNotification = @"JPPVideoPlayerNaturalSizeAvailableNotification";

NSString * const JPPVideoPlayerNowPlayingDidChangeNotification = @"JPPVideoPlayerNowPlayingDidChangeNotification";
NSString * const JPPVideoPlayerPlaybackDidFinishNotification = @"JPPVideoPlayerPlaybackDidFinishNotification";
NSString * const JPPVideoPlayerTimedMetadataNotification = @"JPPVideoPlayerTimedMetadataNotification";

NSString * const JPPVideoPlayerRateChangedNotification = @"JPPVideoPlayerRateChangedNotification";

NSString * const JPPVideoPlayerPlaybackDidFinishReasonUserInfoKey = @"JPPVideoPlayerPlaybackDidFinishReasonUserInfoKey";
NSString * const JPPVideoPlayerPlaybackStateUserInfoKey = @"JPPVideoPlayerPlaybackStateUserInfoKey";
NSString * const JPPVideoPlayerTimedMetadataUserInfoKey = @"JPPVideoPlayerTimedMetadataUserInfoKey";
NSString * const JPPVideoPlayerPlaybackUserInteractionInfoKey = @"JPPVideoPlayerPlaybackUserInteractionInfoKey";

NSString * const JPPVideoPlayeRateChangedRateInfoKey = @"JPPVideoPlayeRateChangedRateInfoKey";


@implementation JPPVideoPlayerController

@dynamic movieView, currentPlaybackRate, currentPlaybackTime;
@synthesize playbackState;
@synthesize loadState = _loadState;

- (instancetype)init
{
	return [self initWithDelegate:nil];
}

-(instancetype)initWithDelegate:(id<JPPVideoPlayerControllerDelegate>)delegate
{
	self = [super init];
	if (self)
	{
		_player = [[AVPlayer alloc] init];
		_shouldAutoplay =  YES;
		
		__weak typeof (self) weakSelf = self;
		
		[_player addObserver:self forKeyPath:kAVPlayerCurrentItemKey options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:JPPAVPlayerControllerPlayerCurrentItemContext];
		[_player addObserver:self forKeyPath:kAVPlayerStatusKey options:NSKeyValueObservingOptionNew context:JPPAVPlayerControllerPlaybackStatusContext];
        [_player addObserver:self forKeyPath:kAVPlayerTimedMetadataKey options:NSKeyValueObservingOptionNew context:JPPAVPlayerControllerTimedMetadataContext];
		[_player addObserver:self forKeyPath:kAVPlayerRateKey options:NSKeyValueObservingOptionNew context:JPPAVPlayerControllerRateContext];
		_periodicTimeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
			typeof(self) strongSelf = weakSelf;
			if(!strongSelf.seeking)
			{
				[strongSelf sendActionsForEvent:JPPVideoPlayerControllerEventPlaybackTimeChanged userInfo:nil];
			}
		}];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessibilityClosedCaptioningDidChange:) name:UIAccessibilityClosedCaptioningStatusDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemPlaybackDidFinish) name:AVPlayerItemDidPlayToEndTimeNotification object:_player];
		
		_externalTimeObservers = [[NSMutableSet alloc] init];
		_finishReason = JPPVideoFinishReasonNotFinished;
		[self setDelegate:delegate];
		
		
	}
	return self;
}

- (void)dealloc
{
	[self removeObserversForPlayerItem:_player.currentItem];
	[_player removeTimeObserver:_periodicTimeObserver];
	[_player removeObserver:self forKeyPath:kAVPlayerCurrentItemKey context:JPPAVPlayerControllerPlayerCurrentItemContext];
	[_player removeObserver:self forKeyPath:kAVPlayerStatusKey context:JPPAVPlayerControllerPlaybackStatusContext];
    [_player removeObserver:self forKeyPath:kAVPlayerTimedMetadataKey context:JPPAVPlayerControllerTimedMetadataContext];
	[_player removeObserver:self forKeyPath:kAVPlayerRateKey context:JPPAVPlayerControllerRateContext];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIAccessibilityClosedCaptioningStatusDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_player];
	
	for (id timeObserver in _externalTimeObservers)
	{
		[_player removeTimeObserver:timeObserver];
	}
}

- (void)setDelegate:(id<JPPVideoPlayerControllerDelegate>)delegate
{
	if (delegate != _delegate)
	{
		_delegate = delegate;
		_delegateHas.durationUpdated = [_delegate respondsToSelector:@selector(avPlayerController:didUpdateItemDuration:)];
		_delegateHas.didUpdateCurrentPlaybackTime = [_delegate respondsToSelector:@selector(avPlayerController:didUpdateCurrentPlaybackTime:)];
		_delegateHas.eventOccured = [_delegate respondsToSelector:@selector(avPlayerController:eventOccurred:)];
		_delegateHas.changeTracks = [_delegate respondsToSelector:@selector(avPlayerController:didChangeTracks:)];
		_delegateHas.loadStateChanged = [_delegate respondsToSelector:@selector(avPlayerControllerLoadStateDidChange:)];
		_delegateHas.naturalSize = [_delegate respondsToSelector:@selector(avPlayerController:didUpdateItemNatualSize:)];
		_delegateHas.urlFailed = [_delegate respondsToSelector:@selector(avPlayerController:failedToLoadContentURL:)];
		_delegateHas.rateChanged = [_delegate respondsToSelector:@selector(avPlayerController:rateDidChange:)];
	}
}


- (UIView *)movieView
{
	if(!_playerView)
	{
		//TODO: maybe a CGRectZero here?
		_playerView = [[JPPVideoPlayerView alloc] initWithFrame:CGRectZero];
		_playerView.player = self.player;
	}
	return self.playerView;
}

- (void)setContentURL:(NSURL *)contentURL
{
	_contentURL = [contentURL copy];
	AVPlayerItem *item = [AVPlayerItem playerItemWithURL:_contentURL];
	[item addObserver:self forKeyPath:kAVPlayerItemPlaybackKey options:NSKeyValueObservingOptionNew context:JPPAVPlayerControllerPlayerItemStatusContext];
	[item addObserver:self forKeyPath:kAVPlayerItemEmptyBufferKey options:NSKeyValueObservingOptionNew context:JPPAVPlayerControllerPlayerItemStatusContext];
	[item addObserver:self forKeyPath:kAVPlayerItemTracksKey options:NSKeyValueObservingOptionNew context:JPPAVPlayerControllerPlayerItemStatusContext];
	[self loadTracksForItem:item completion:^(BOOL completed) {
		if(completed)
		{
			[self.player replaceCurrentItemWithPlayerItem:item];
			[self loadDurationAndMetadataForItem:item];
		}
		else
		{
			[self removeObserversForPlayerItem:item];
		}
	}];
}

- (AVPlayerItem *)playerItem
{
	return self.player.currentItem;
}

- (BOOL)isSeeking
{
	return self.playbackState == JPPVideoPlaybackStateSeekingBackward || self.playbackState == JPPVideoPlaybackStateSeekingForward;
}

- (void)loadTracksForItem:(AVPlayerItem *)item completion:(void(^)(BOOL completed))completion
{
	[item.asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
		if([item.asset statusOfValueForKey:@"tracks" error:nil] == AVKeyValueStatusLoaded)
		{
			completion(YES);
		}
		else if ([item.asset statusOfValueForKey:@"tracks" error:nil] == AVKeyValueStatusFailed)
		{
			completion(NO);
			if(_delegateHas.urlFailed)
			{
				dispatch_async(dispatch_get_main_queue(), ^{
					[self.delegate avPlayerController:self failedToLoadContentURL:self.contentURL];
				});
			}
		}
	}];
}


- (void)loadDurationAndMetadataForItem:(AVPlayerItem *)item;
{
	AVAsset *asset = item.asset;
	[asset loadValuesAsynchronouslyForKeys:@[@"duration", @"naturalSize"] completionHandler:^{
		if(self.player.currentItem.asset == asset)
		{
			if([asset statusOfValueForKey:@"duration" error:nil] == AVKeyValueStatusLoaded)
			{
				dispatch_async(dispatch_get_main_queue(), ^{
					[self sendActionsForEvent:JPPVideoPlayerControllerEventDurationAvailable userInfo:nil];
				});
			}
			
			if([asset statusOfValueForKey:@"naturalSize" error:nil] == AVKeyValueStatusLoaded)
			{
				dispatch_async(dispatch_get_main_queue(), ^{
					[self sendActionsForEvent:JPPVideoPlayerControllerEventNaturalSizeAvailable userInfo:nil];
				});
			}
			
			if(_shouldAutoplay)
			{
				[self play];
			}
		}
	}];
}

- (void)prepareToPlay
{
	
}

- (BOOL)isPreparedToPlay
{
	return self.player.status == AVPlayerItemStatusReadyToPlay;
}

- (void)play
{
	[self playFromUserInteraction:NO];
}

- (void)pause
{
	[self pause:NO];
}

- (void)playFromUserInteraction:(BOOL)userInteraction
{
	if ([self isPreparedToPlay])
	{
        if(self.currentPlaybackTime == self.duration)
        {
            [self.player seekToTime:kCMTimeZero];
        }
//		self.loadState = JPPAVLoadStatePlaythroughOK;
		[self.player play];
        self.previousPlaybackState = self.playbackState;
        self.playbackState = JPPVideoPlaybackStatePlaying;
        
        NSDictionary *dictionary = @{JPPVideoPlayerPlaybackStateUserInfoKey : @(JPPVideoPlaybackStatePlaying), JPPVideoPlayerPlaybackUserInteractionInfoKey : [NSNumber numberWithBool:userInteraction]};
		[self sendActionsForEvent:JPPVideoPlayerControllerEventPlaybackDidChange userInfo:dictionary];
        
	}
	else
	{
		_shouldPlayWhenPossible = YES;
		[self prepareToPlay];
	}
}

- (void)pauseFromUserInteraction:(BOOL)userInteraction stalledPause:(BOOL)stalledPause
{
	[self.player pause];
    self.previousPlaybackState = self.playbackState;
    self.playbackState = JPPVideoPlaybackStatePaused;
	
	NSDictionary *dictionary = @{JPPVideoPlayerPlaybackStateUserInfoKey : @(JPPVideoPlaybackStatePlaying), JPPVideoPlayerPlaybackUserInteractionInfoKey : [NSNumber numberWithBool:userInteraction]};
	[self sendActionsForEvent:JPPVideoPlayerControllerEventPlaybackDidChange userInfo:dictionary];
	
	// This flag indicates whether the player should resume playback.  If the user or client initiates a pause, we don't want to
	// autoplay even if our state changes
	_shouldPlayWhenPossible = stalledPause;
}

- (void)pause:(BOOL)stalledPause
{
	[self pauseFromUserInteraction:NO stalledPause:stalledPause];
}

- (void)stop
{
	[self pause];
	[self.player seekToTime:kCMTimeZero];
    self.previousPlaybackState = self.playbackState;
    self.playbackState = JPPVideoPlaybackStateStopped;
    
    NSDictionary *dictionary = @{JPPVideoPlayerPlaybackStateUserInfoKey : @(JPPVideoPlaybackStateStopped)};
    [self sendActionsForEvent:JPPVideoPlayerControllerEventPlaybackDidChange userInfo:dictionary];
}

- (void)beginSeekingBackward
{
	// TODO: Implement
    self.previousPlaybackState = self.playbackState;
    self.playbackState = JPPVideoPlaybackStateSeekingBackward;
    
    NSDictionary *dictionary = @{JPPVideoPlayerPlaybackStateUserInfoKey : @(JPPVideoPlaybackStateSeekingBackward)};
    [self sendActionsForEvent:JPPVideoPlayerControllerEventPlaybackDidChange userInfo:dictionary];
	self.player.rate = -2.0;
}

- (void)beginSeekingForward
{
	// TODO: Implement
    self.previousPlaybackState = self.playbackState;
    self.playbackState = JPPVideoPlaybackStateSeekingForward;
    
    NSDictionary *dictionary = @{JPPVideoPlayerPlaybackStateUserInfoKey : @(JPPVideoPlaybackStateSeekingForward)};
    [self sendActionsForEvent:JPPVideoPlayerControllerEventPlaybackDidChange userInfo:dictionary];
	self.player.rate = 2.0;
	NSLog(@"player rate = %f", self.player.rate);
}

- (void)endSeeking
{
	self.player.rate = 1.0;
    if (self.previousPlaybackState == JPPVideoPlaybackStatePlaying || self.previousPlaybackState == JPPVideoPlaybackStateStopped || [self shouldPlayWhenPossible])
	{
        [self play];
	}
    else if (self.previousPlaybackState == JPPVideoPlaybackStatePaused)
	{
        [self pause];
	}
}


#pragma mark - Timing

- (BOOL)canSeekForward
{
	return self.playerItem.canPlayFastForward;
}

- (BOOL)canSeekBackward
{
	return self.playerItem.canPlayFastReverse;
}

- (NSTimeInterval)duration
{
	if(CMTIME_IS_NUMERIC(self.playerItem.duration) && CMTIME_IS_VALID(self.playerItem.duration))
	{
		return CMTimeGetSeconds(self.playerItem.duration);
	}
	if(CMTIME_IS_INDEFINITE(self.playerItem.duration))
	{
		return -1.0;
	}
	return 0.0;
}

- (void)setCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime
{
	[self.player.currentItem cancelPendingSeeks];
	CMTime time = CMTimeMake(currentPlaybackTime, 1);
	if(CMTIME_IS_VALID(time) && self.player.currentItem.status == AVPlayerItemStatusReadyToPlay)
	{
		int32_t result = CMTimeCompare(time, self.player.currentTime);
		if(result < 0)
		{
			self.playbackState = JPPVideoPlaybackStateSeekingBackward;
		}
		if (result > 0)
		{
			self.playbackState = JPPVideoPlaybackStateSeekingForward;
		}
		NSDictionary *dictionary = @{JPPVideoPlayerPlaybackStateUserInfoKey : @(self.playbackState)};
		[self sendActionsForEvent:JPPVideoPlayerControllerEventPlaybackDidChange userInfo:dictionary];
		[self.player seekToTime:time completionHandler:^(BOOL finished) {
			if (finished)
			{
				self.playbackState = JPPVideoPlaybackStatePlaying;
				NSDictionary *dictionary = @{JPPVideoPlayerPlaybackStateUserInfoKey : @(self.playbackState)};
				dispatch_async(dispatch_get_main_queue(), ^{
					[self sendActionsForEvent:JPPVideoPlayerControllerEventPlaybackDidChange userInfo:dictionary];
					[self sendActionsForEvent:JPPVideoPlayerControllerEventPlaybackTimeChanged userInfo:nil];
				});
			}
		}];
	}
}

- (NSTimeInterval)currentPlaybackTime
{
	return MAX(CMTimeGetSeconds(self.player.currentTime), 0);
}

- (float)currentPlaybackRate
{
	return self.player.rate;
}

#pragma mark - autoplay

- (BOOL)canAutoplay
{
	return self.shouldAutoplay && _shouldPlayWhenPossible;
}

- (BOOL)shouldPlayWhenPossible
{
	return _shouldPlayWhenPossible;
}

#pragma mark - KVO and notifications

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == JPPAVPlayerControllerPlaybackStatusContext)
	{
		/*if ([keyPath isEqualToString:kAVPlayerStatusKey] && _shouldPlayWhenPossible && self.player.status == AVPlayerStatusReadyToPlay)
		{
			_shouldPlayWhenPossible = NO;
			[self play];
		}
		else*/ if ([keyPath isEqualToString:kAVPlayerStatusKey] && self.player.status == AVPlayerStatusFailed)
		{
			_error = self.player.error;
			self.playbackState = JPPVideoPlaybackStateInterrupted;
			self.finishReason = JPPVideoFinishReasonPlaybackError;
			NSDictionary *dictionary = @{JPPVideoPlayerPlaybackDidFinishReasonUserInfoKey : @(JPPVideoFinishReasonPlaybackError)};
			[self sendActionsForEvent:JPPVideoPlayerControllerEventPlaybackDidChange userInfo:dictionary];
		}
	}
	else if (context == JPPAVPlayerControllerPlayerItemStatusContext)
	{
		if ([keyPath isEqualToString:kAVPlayerItemPlaybackKey] && self.player.currentItem.isPlaybackLikelyToKeepUp)
		{
			self.loadState = JPPVideoLoadStatePlayable;
		}
		else if ([keyPath isEqualToString:kAVPlayerItemEmptyBufferKey])
		{
			if (self.player.currentItem.isPlaybackBufferEmpty)
			{
				// Stall
				self.loadState = JPPVideoLoadStateStalled;
				
//				if (self.playbackState == JPPAVPlaybackStatePlaying)
//				{
//					[self pause:YES];
//				}
			}
			else
			{
				self.loadState = JPPVideoLoadStateUnknown;
			}
		}
		else if ([keyPath isEqualToString:kAVPlayerItemTracksKey])
		{
			[self sendActionsForEvent:JPPVideoPlayerControllerEventNowPlayingChanged userInfo:nil];
			//[self playerItemDidChangeTracks:self.player.currentItem];
		}
	}
	else if (context == JPPAVPlayerControllerPlayerCurrentItemContext)
	{
		if ([keyPath isEqualToString:kAVPlayerCurrentItemKey])
		{
			AVPlayerItem *item = [change valueForKey:NSKeyValueChangeOldKey];
			if (item != (id)[NSNull null])
			{
				[self removeObserversForPlayerItem:item];
			}
			
			if ([change valueForKey:NSKeyValueChangeNewKey] != (id)[NSNull null])
			{
				[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemPlaybackDidFinish) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
			}
			else
			{
                if (item != (id)[NSNull null])
                    _error = item.error;
                else
				{
                    _error = [NSError errorWithDomain:NSURLErrorDomain code:-1100 userInfo:@{NSLocalizedDescriptionKey : @"The requested URL was not found on this server."}];
				}
                
				self.playbackState = JPPVideoPlaybackStateInterrupted;
				self.finishReason = JPPVideoFinishReasonPlaybackError;
				NSDictionary *dictionary = @{JPPVideoPlayerPlaybackDidFinishReasonUserInfoKey : @(JPPVideoFinishReasonPlaybackError)};
				[self sendActionsForEvent:JPPVideoPlayerControllerEventPlaybackDidChange userInfo:dictionary];
			}
		}
	}
    else if (context == JPPAVPlayerControllerTimedMetadataContext)
    {
        if ([keyPath isEqualToString:kAVPlayerTimedMetadataKey])
        {
            NSArray *metadataArray = self.player.currentItem.timedMetadata;
            
            if (metadataArray)
            {
                NSDictionary *dictionary = @{JPPVideoPlayerTimedMetadataUserInfoKey : metadataArray};
                [[NSNotificationCenter defaultCenter] postNotificationName:JPPVideoPlayerTimedMetadataNotification object:dictionary];
            }
        }
    }
	else if(context == JPPAVPlayerControllerRateContext)
	{
		if ([keyPath isEqualToString:kAVPlayerRateKey])
		{
			NSDictionary *dictionary = @{JPPVideoPlayeRateChangedRateInfoKey : @([object rate])};
			[self sendActionsForEvent:JPPVideoPlayerControllerEventRateChanged userInfo:dictionary];
		}
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)playerItemPlaybackDidFinish
{
	self.finishReason = JPPVideoFinishReasonPlaybackEnded;
    self.playbackState = JPPVideoPlaybackStateStopped;
	NSDictionary *dictionary = @{JPPVideoPlayerPlaybackDidFinishReasonUserInfoKey : @(JPPVideoFinishReasonPlaybackEnded)};
	
	[self sendActionsForEvent:JPPVideoPlayerControllerEventPlaybackDidChange userInfo:dictionary];

}

- (void)setFullscreen:(BOOL)fullscreen
{
	[self setFullscreen:fullscreen animated:NO];
}

- (void)setFullscreen:(BOOL)fullscreen animated:(BOOL)animated
{
	if (!_playerView.superview || fullscreen == _fullscreen)
	{
		return;
	}
	
	_fullscreen = fullscreen;
	NSTimeInterval animationDuration = animated ? 0.25 : 0.0;
	
	if (_fullscreen)
	{
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
		[self sendActionsForEvent:JPPVideoPlayerControllerEventWillEnterFullscreen userInfo:nil];
		
		self.preFullscreenAutoresizing = _playerView.autoresizingMask;
		self.preFullscreenFrame = _playerView.frame;
		self.preFullscreenSuperview = _playerView.superview;
		self.preFullscreenSubviewIndex = [_playerView.superview.subviews indexOfObject:_playerView];
		self.isPreFullscreenStatusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
		self.preFullscreenStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
		
		UIView *parent = _playerView.window.rootViewController.view;
		
		CGRect frame = [_playerView convertRect:_playerView.bounds toView:parent];
		[_playerView removeFromSuperview];
		[parent addSubview:_playerView];
		_playerView.frame = frame;
		[UIView animateWithDuration:animationDuration animations:^{
			_playerView.frame = parent.frame;
			_playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		} completion:^(BOOL finished) {
			[self sendActionsForEvent:JPPVideoPlayerControllerEventDidEnterFullscreen userInfo:nil];
		}];
	}
	else
	{
        [[UIApplication sharedApplication] setStatusBarStyle:self.preFullscreenStatusBarStyle animated:animated];
		[self sendActionsForEvent:JPPVideoPlayerControllerEventWillExitFullscreen userInfo:nil];
		CGRect convertedRect = [self.preFullscreenSuperview convertRect:_playerView.frame fromView:[_playerView superview]];
		[_playerView removeFromSuperview];
		[self.preFullscreenSuperview insertSubview:_playerView atIndex:self.preFullscreenSubviewIndex];
		_playerView.frame = convertedRect;
		[UIView animateWithDuration:animationDuration animations:^{
			_playerView.frame = self.preFullscreenFrame;
			_playerView.autoresizingMask = self.preFullscreenAutoresizing;
		} completion:^(BOOL finished) {
			[self sendActionsForEvent:JPPVideoPlayerControllerEventDidExitFullscreen userInfo:nil];
		}];
	}
}

#pragma mark - scaling mode
- (void)setScalingMode:(JPPVideoScalingMode)scalingMode
{
	if(_scalingMode == scalingMode)
	{
		_scalingMode = scalingMode;
		_playerView.playerLayer.videoGravity = [self contentGravityForScalingMode:_scalingMode];
		[self sendActionsForEvent:JPPVideoPlayerControllerEventScalingModeChanged userInfo:nil];
	}
}

- (CGSize)naturalSize
{
	// Enumerate over the tracks and find one with a non-zero natural size (implying a video track)
	for (AVPlayerItemTrack *track in self.player.currentItem.tracks)
	{
		if (!CGSizeEqualToSize(track.assetTrack.naturalSize, CGSizeZero))
			return track.assetTrack.naturalSize;
	}
	
	return CGSizeZero;
}

- (void)setAllowsAirPlay:(BOOL)allowsAirPlay
{
	self.player.allowsExternalPlayback = YES;
}

- (BOOL)allowsAirPlay
{
	return self.player.allowsExternalPlayback;
}

- (BOOL)isAirPlayVideoActive
{
	return self.player.externalPlaybackActive;
}

#pragma mark - time observation

- (id)addBoundaryTimeObserverForTimes:(NSArray *)times queue:(dispatch_queue_t)queue usingBlock:(void (^)(void))block
{
	NSAssert(times.count, @"can't pass in nil times");
    if (!times.count)
    {
        return nil;
    }
    
	id timeObserver = [self.player addBoundaryTimeObserverForTimes:times queue:queue usingBlock:block];
	[_externalTimeObservers addObject:timeObserver];
	return timeObserver;
}

- (void)removeTimeObserver:(id)timeObserver
{
	[self.player removeTimeObserver:timeObserver];
	if ([_externalTimeObservers containsObject:timeObserver])
	{
		[_externalTimeObservers removeObject:timeObserver];
	}
}


#pragma mark - Closed Captioning

- (void)accessibilityClosedCaptioningDidChange:(NSNotification *)notification
{
	if (self.closedCaptioningMode == JPPVideoPlayerClosedCaptioningDefault)
	{
		[self setClosedCaptioningDisplayEnabled:UIAccessibilityIsClosedCaptioningEnabled()];
	}
}

- (JPPVideoPlayerClosedCaptioningMode)closedCaptioningMode
{
	return _closedCaptioningMode;
}

- (void)setClosedCaptioningMode:(JPPVideoPlayerClosedCaptioningMode)closedCaptioningMode
{
	if (closedCaptioningMode == _closedCaptioningMode)
	{
		return;
	}
	
	_closedCaptioningMode = closedCaptioningMode;
	BOOL closedCaptionDisplayEnabled = [self shouldEnableClosedCaptioningForMode:closedCaptioningMode];
	
	[self setClosedCaptioningDisplayEnabled:closedCaptionDisplayEnabled];
}

- (BOOL)shouldEnableClosedCaptioningForMode:(JPPVideoPlayerClosedCaptioningMode)closedCaptioningMode
{
	BOOL closedCaptionDisplayEnabled = NO;
	
	switch (closedCaptioningMode) {
		case JPPVideoPlayerClosedCaptioningDefault:
			closedCaptionDisplayEnabled = UIAccessibilityIsClosedCaptioningEnabled();
			break;
		case JPPVideoPlayerClosedCaptioningOff:
			closedCaptionDisplayEnabled = NO;
			break;
		case JPPVideoPlayerClosedCaptioningOn:
			closedCaptionDisplayEnabled = YES;
		default:
			break;
	}
	
	return closedCaptionDisplayEnabled;
}

- (void)setClosedCaptioningDisplayEnabled:(BOOL)enabled
{
	if (self.closedCaptioningCallback)
	{
		self.closedCaptioningCallback(enabled);
	}
	else
	{
		self.player.closedCaptionDisplayEnabled = enabled;
	}
}

- (void)setClosedCaptioningCallback:(JPPVideoPlayerControllerClosedCaptionToggleCallback)closedCaptioningCallback
{
	_closedCaptioningCallback = [closedCaptioningCallback copy];
	if (_closedCaptioningCallback)
	{
		_closedCaptioningCallback([self shouldEnableClosedCaptioningForMode:self.closedCaptioningMode]);
	}
}

- (JPPVideoPlayerControllerClosedCaptionToggleCallback)closedCaptioningCallback
{
	return _closedCaptioningCallback;
}

- (BOOL)isClosedCaptioningAvailable
{
	for(AVPlayerItemTrack *itemTrack in self.player.currentItem.tracks)
	{
		if([itemTrack.assetTrack.mediaType isEqualToString:AVMediaTypeClosedCaption])
		{
			return YES;
		}
	}
	return NO;
}

#pragma mark - Load State

- (void)setLoadState:(JPPVideoLoadState)loadState
{
	if (_loadState == loadState)
		return;
	
	_loadState = loadState;
	[self sendActionsForEvent:JPPVideoPlayerControllerEventLoadStateChanged userInfo:nil];
}


#pragma mark - helpers

- (void)removeObserversForPlayerItem:(AVPlayerItem *)playerItem
{
	[playerItem removeObserver:self forKeyPath:kAVPlayerItemPlaybackKey];
	[playerItem removeObserver:self forKeyPath:kAVPlayerItemEmptyBufferKey];
	[playerItem removeObserver:self forKeyPath:kAVPlayerItemTracksKey];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)sendActionsForEvent:(JPPVideoPlayerControllerEvent)event userInfo:(NSDictionary *)userInfo
{
	if(_delegateHas.eventOccured)
	{
		[self.delegate avPlayerController:self eventOccurred:event];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:JPPVideoPlayerEventOccurredNotification object:self userInfo:@{JPPVideoPlayerEventOccurredUserInfoKey : @(event)}];
	
	NSString *notificationName = nil;
	switch (event) {
		case JPPVideoPlayerControllerEventPlaybackDidChange:
			if(_delegateHas.playStateChanged)
			{
				[self.delegate avPlayerControllerPlayStateDidChange:self];
			}
			notificationName = JPPVideoPlayerPlaybackStateDidChangeNotification;
			break;
		case JPPVideoPlayerControllerEventWillEnterFullscreen:
			notificationName = JPPVideoPlayerWillEnterFullscreenNotification;
			break;
		case JPPVideoPlayerControllerEventDidEnterFullscreen:
			notificationName = JPPVideoPlayerDidEnterFullscreenNotification;
			break;
		case JPPVideoPlayerControllerEventWillExitFullscreen:
			notificationName = JPPVideoPlayerWillExitFullscreenNotification;
			break;
		case JPPVideoPlayerControllerEventDidExitFullscreen:
			notificationName = JPPVideoPlayerDidExitFullscreenNotification;
			break;
		case JPPVideoPlayerControllerEventScalingModeChanged:
			notificationName = JPPVideoPlayerScalingModeDidChangeNotification;
			break;
		case JPPVideoPlayerControllerEventPlaybackTimeChanged:
			if(_delegateHas.didUpdateCurrentPlaybackTime)
			{
				[self.delegate avPlayerController:self didUpdateCurrentPlaybackTime:[self currentPlaybackTime]];
			}
			notificationName = JPPVideoPlayerCurrentPlaybackTimeDidChangeNotification;
			break;
		case JPPVideoPlayerControllerEventDurationAvailable:
			if(_delegateHas.durationUpdated)
			{
				CMTime time = self.player.currentItem.asset.duration;
				[self.delegate avPlayerController:self didUpdateItemDuration:time];
			}
			notificationName = JPPVideoPlayerDurationAvailableNotification;
			break;
		case JPPVideoPlayerControllerEventNaturalSizeAvailable:
			if(_delegateHas.naturalSize)
			{
				[self.delegate avPlayerController:self didUpdateItemNatualSize:[self naturalSize]];
			}
			notificationName = JPPVideoPlayerNaturalSizeAvailableNotification;
			break;
		case JPPVideoPlayerControllerEventLoadStateChanged:
			if(_delegateHas.loadStateChanged)
			{
				[self.delegate avPlayerControllerLoadStateDidChange:self];
			}
			notificationName = JPPVideoPlayerLoadStateDidChangeNotification;
			break;
		case JPPVideoPlayerControllerEventNowPlayingChanged:
			if (_delegateHas.changeTracks)
			{
				[self.delegate avPlayerController:self didChangeTracks:self.player.currentItem];
			}
			notificationName = JPPVideoPlayerNowPlayingDidChangeNotification;
			break;
		case JPPVideoPlayerControllerEventRateChanged:
			if(_delegateHas.rateChanged)
			{
				[self.delegate avPlayerController:self rateDidChange:self.player.rate];
			}
			notificationName = JPPVideoPlayerRateChangedNotification;
			break;
		default:
			notificationName = nil;
			break;
	}
    
	if (notificationName)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:userInfo];
	}
}

- (NSString *)contentGravityForScalingMode:(JPPVideoScalingMode)scalingMode
{
	NSString *gravity = nil;
	
	switch (scalingMode) {
		case JPPVideoScalingModeNone:
		case JPPVideoScalingModeFill:
			gravity = AVLayerVideoGravityResize;
			break;
		case JPPVideoScalingModeAspectFill:
			gravity = AVLayerVideoGravityResizeAspectFill;
			break;
		case JPPVideoScalingModeAspectFit:
			gravity = AVLayerVideoGravityResizeAspect;
			break;
	}
	return gravity;
}

@end
