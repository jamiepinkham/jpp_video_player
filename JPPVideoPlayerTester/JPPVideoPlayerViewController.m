//
//  JPPVideoPlayerViewController.m
//  JPPVideoPlayerTester
//
//  Created by Jamie Pinkham on 8/15/13.
//  Copyright (c) 2013 Jamie Pinkham. All rights reserved.
//

#import "JPPVideoPlayerViewController.h"
#import "JPPVideoPlayer/JPPVideoPlayer.h"
#import <MediaPlayer/MediaPlayer.h>
#import "JPPSkipBackControl.h"

@interface JPPVideoPlayerViewController () <JPPVideoPlayerControllerDelegate, JPPCuePointSliderDelegate>

@property (nonatomic, strong) UIView *playerContainerView;
@property (nonatomic, strong) JPPVideoPlayerController *playerController;
@property (nonatomic, strong) JPPPlaybackControlsBar *transportControls;
@property (nonatomic, strong) JPPControlContainer *topLeftContainer;
@property (nonatomic, strong) JPPCuePointSlider *slider;

@end

@implementation JPPVideoPlayerViewController

- (instancetype)initWithURL:(NSURL *)aURL
{
	self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	if (self)
	{
		self.playerController = [[JPPVideoPlayerController alloc] initWithDelegate:self];
		self.playerController.shouldAutoplay = YES;
		self.playerController.contentURL = aURL;
	}
	return self;
}


- (void)loadView
{
	self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.view.translatesAutoresizingMaskIntoConstraints = NO;
	self.view.backgroundColor = [UIColor redColor];
	self.playerContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 400)];
	self.playerContainerView.translatesAutoresizingMaskIntoConstraints = NO;
	self.playerContainerView.backgroundColor = [UIColor orangeColor];
	self.playerContainerView.center = self.view.center;
	
	[self.playerContainerView addSubview:self.playerController.movieView];
	[[self view] addSubview:self.playerContainerView];
	
	self.playerController.movieView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	self.playerController.movieView.frame = CGRectMake(0, 0, CGRectGetWidth(self.playerContainerView.frame), CGRectGetHeight(self.playerContainerView.frame));
	self.playerController.movieView.backgroundColor = [UIColor clearColor];
	
	
	self.transportControls = [[JPPPlaybackControlsBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 44.0f)];
	self.transportControls.player = self.playerController;
	self.transportControls.shouldShowLoadingIndicator = YES;
	
	JPPPlayPauseControl *playControl = [[JPPPlayPauseControl alloc] init];
	
	self.slider = [[JPPCuePointSlider alloc] init];
	self.slider.delegate = self;
	self.slider.toolbarWidth = 200;
	
	JPPAirplayControl *airplayButton = [[JPPAirplayControl alloc] init];
	airplayButton.backgroundColor = [UIColor lightGrayColor];
	
	JPPSkipBackControl *skipBack = [[JPPSkipBackControl alloc] init];
	skipBack.skipBackSeconds = 10;
	[skipBack sizeToFit];
	
	JPPClosedCaptioningControl *ccControl = [[JPPClosedCaptioningControl alloc] init];
	[ccControl sizeToFit];
	
	[self.transportControls setPlaybackControls:@[playControl, self.slider, airplayButton]];
	
	[self.playerController.movieView addSubview:self.transportControls];

	
	JPPFullscreenToggleControl *fullscreenToggle = [[JPPFullscreenToggleControl alloc] init];
	[fullscreenToggle sizeToFit];
	
	JPPTimeLabelControl *timeLabel = [[JPPTimeLabelControl alloc] initWithFrame:CGRectMake(CGRectGetMaxX(fullscreenToggle.frame) + 10.0f, 0, 50, 50)];
	
	NSString *(^timeLabelFormatter)(NSTimeInterval duration) = ^NSString *(NSTimeInterval timeInterval){
		NSInteger minutes = timeInterval / 60.0;
		NSInteger seconds = fmodf(timeInterval, 60.0f);
		
		return [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
	};
	
	timeLabel.durationTimeFormatter = timeLabelFormatter;
	timeLabel.currentPlaybackTimeFormatter = timeLabelFormatter;
	
	[self.topLeftContainer setPlaybackControls:@[fullscreenToggle, timeLabel]];
	[self.playerController.movieView addSubview:self.topLeftContainer];
	
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.transportControls.frame = CGRectMake(0.0f, CGRectGetHeight(self.playerContainerView.bounds) - CGRectGetHeight(self.transportControls.bounds), CGRectGetWidth(self.playerContainerView.bounds), CGRectGetHeight(self.transportControls.bounds));
	self.transportControls.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
	

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - JPPVideoPlayerDelegate methods
- (void)avPlayerControllerLoadStateDidChange:(JPPVideoPlayerController *)avPlayerController
{
	
}

- (void)avPlayerController:(JPPVideoPlayerController *)avPlayerController didUpdateCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime
{
	
}

- (void)avPlayerController:(JPPVideoPlayerController *)avPlayerController itemDidFinishForReason:(JPPVideoFinishReason)reason
{
	
}

- (void)avPlayerController:(JPPVideoPlayerController *)avPlayerController eventOccurred:(JPPVideoPlayerControllerEvent)event
{
	
}

- (void)avPlayerController:(JPPVideoPlayerController *)avPlayerController didChangeTracks:(AVPlayerItem *)playerItem
{

}

- (void)avPlayerController:(JPPVideoPlayerController *)avPlayerController rateDidChange:(CGFloat)currentRate
{
	NSLog(@"rate = %@, playback state = %@", @(currentRate), @([avPlayerController playbackState]));
}

#pragma mark - JPPCuePointSliderDelegate methods

- (void)slider:(JPPCuePointSlider *)slider didChangeValue:(float)value
{
	[self.playerController setCurrentPlaybackTime:value];
}

- (void)sliderTrackingDidCancel:(JPPCuePointSlider *)slider
{
	[self.playerController endSeeking];
}

- (void)sliderTrackingDidEnd:(JPPCuePointSlider *)slider
{
	[self.playerController endSeeking];
}

- (void)sliderTrackingDidBegin:(JPPCuePointSlider *)slider
{

}

@end
