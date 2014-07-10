//
//  JPPPlayPauseButton.m
//  JPPVideoPlayerTester
//
//  Created by Jamie Pinkham on 9/6/13.
//  Copyright (c) 2013 Bottle Rocket. All rights reserved.
//

#import "JPPPlayPauseControl.h"
#import "JPPVideoPlayerFunctions.h"
#import "JPPVideoPlayerController.h"

@interface JPPPlayPauseControl ()

@property (nonatomic, strong) NSMutableDictionary *controlImages;
@property (nonatomic, strong) UIButton *playButton;

@end

NSString * const kPlayImagesSet = @"play_images";
NSString * const kPauseImageSet = @"pause_images";

@implementation JPPPlayPauseControl

+ (void)initialize
{
	
	NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"JPPVideoPlayerResources" withExtension:@"bundle"];

	if(bundleURL == nil)
	{
		NSLog(@"bundle url is nil, did you forget to copy the resource bundle? falling back to the main bundle");
		bundleURL = [[NSBundle mainBundle] bundleURL];
	}

	NSBundle *libraryBundle = [NSBundle bundleWithURL:bundleURL];
	UIImage *playButtonImage = JPP_bundleImageNamed(@"video_play", libraryBundle);
	UIImage *playButtonSelectedImage = JPP_bundleImageNamed(@"video_play_touch", libraryBundle);

	UIImage *pauseButtonImage = JPP_bundleImageNamed(@"video_pause", libraryBundle);
	UIImage *pauseButtonSelectedImage = JPP_bundleImageNamed(@"video_pause_touch", libraryBundle);
	
	JPPPlayPauseControl *control = [self appearance];
	[control setPlayImage:playButtonImage forState:UIControlStateNormal];
	[control setPlayImage:playButtonSelectedImage forState:UIControlStateHighlighted];
	[control setPauseImage:pauseButtonImage forState:UIControlStateNormal];
	[control setPauseImage:pauseButtonSelectedImage forState:UIControlStateHighlighted];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
		[self JPPPlayButtonCommonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		[self JPPPlayButtonCommonInit];
	}
	return self;
}

- (void)JPPPlayButtonCommonInit
{
	[self addSubview:self.playButton];
	[self.playButton sizeToFit];
	self.frame = self.playButton.frame;
}

- (CGSize)sizeThatFits:(CGSize)size
{
	return [self.playButton sizeThatFits:size];
}

- (void)sizeToFit
{
	[self.playButton sizeToFit];
	self.frame = self.playButton.frame;
}

- (NSMutableDictionary *)controlImages
{
	if(_controlImages == nil)
	{
		_controlImages = [[NSMutableDictionary alloc] init];
	}
	return _controlImages;
}

- (UIButton *)playButton
{
	if(_playButton == nil)
	{
		_playButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	}
	return _playButton;
}

- (void)setPlayImage:(UIImage *)image forState:(UIControlState)controlState
{
	[self setImage:image forKey:kPlayImagesSet controlState:controlState];
	[self setUpButtonForPlayState:self.avPlayerController.playbackState];
}

- (void)setPauseImage:(UIImage *)image forState:(UIControlState)controlState
{
	[self setImage:image forKey:kPauseImageSet controlState:controlState];
	[self setUpButtonForPlayState:self.avPlayerController.playbackState];
}

- (JPPVideoPlayerControllerEventMask)supportedEvents
{
	return JPPVideoPlayerControllerEventMaskPlaybackDidChange;
}

- (void)setAvPlayerController:(JPPVideoPlayerController *)avPlayerController
{
	[super setAvPlayerController:avPlayerController];
	[self setUpButtonForPlayState:[avPlayerController playbackState]];
}

- (void)playerController:(JPPVideoPlayerController *)aPlayer eventOccurred:(JPPVideoPlayerControllerEvent)event
{
	if(event == JPPVideoPlayerControllerEventPlaybackDidChange)
	{
		[self setUpButtonForPlayState:[aPlayer playbackState]];
	}
}


- (void)setUpButtonForPlayState:(JPPVideoPlaybackState)playbackState
{
	if(playbackState == JPPVideoPlaybackStatePlaying)
	{
		[self applyImagesForKey:kPauseImageSet];
	}
	else
	{
		[self applyImagesForKey:kPlayImagesSet];
	}
}

- (void)playButtonAction:(id)sender
{
	if (self.avPlayerController.currentPlaybackRate > 0.0f)
	{
		[self.avPlayerController pauseFromUserInteraction:YES stalledPause:NO];
	}
	else
	{
		[self.avPlayerController playFromUserInteraction:YES];
	}
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key controlState:(UIControlState)state
{
	NSMutableDictionary *images = self.controlImages[key];
	if(!images)
	{
		images = [[NSMutableDictionary alloc] init];
		self.controlImages[key] = images;
	}
	
	if(image)
	{
		images[@(state)] = image;
	}
	else
	{
		[images removeObjectForKey:@(state)];
	}
}

- (void)applyImagesForKey:(NSString *)key
{
	NSDictionary *images = [self.controlImages objectForKey:key];
	[images enumerateKeysAndObjectsUsingBlock:^(NSNumber *stateKey, UIImage *image, BOOL *stop) {
		UIControlState state = [stateKey integerValue];
		[self.playButton setImage:image forState:state];
	}];
}

@end
