//
//  JPPFullscreenToggleControl.m
//  JPPVideoPlayerTester
//
//  Created by Jamie Pinkham on 9/6/13.
//  Copyright (c) 2013 Jamie Pinkham. All rights reserved.
//

#import "JPPFullscreenToggleControl.h"
#import "JPPVideoPlayerFunctions.h"
#import "JPPVideoPlayerController.h"

@interface JPPFullscreenToggleControl ()

@property (nonatomic, strong) NSMutableDictionary *controlImages;
@property (nonatomic, strong) UIButton *fullScreenButton;

@end

NSString * const kFullScreenImageSet = @"full_screen";
NSString * const kInlineImageSet = @"inline";

@implementation JPPFullscreenToggleControl

+ (void)initialize
{
	JPPFullscreenToggleControl *control = [self appearance];
	NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"JPPVideoPlayerResources" withExtension:@"bundle"];

	if(bundleURL == nil)
	{
		NSLog(@"bundle url is nil, did you forget to copy the resource bundle? falling back to the main bundle");
		bundleURL = [[NSBundle mainBundle] bundleURL];
	}

	NSBundle *libraryBundle = [NSBundle bundleWithURL:bundleURL];
	UIImage *videoFullscreenButtonImage = JPP_bundleImageNamed(@"video_fullscreen", libraryBundle);
	UIImage *videoFullscreenButtonSelectedImage = JPP_bundleImageNamed(@"video_fullscreen_touch", libraryBundle);

	UIImage *videoInlineButtonImage = JPP_bundleImageNamed(@"video_letterbox", libraryBundle);
	UIImage *videoInlineButtonSelectedImage =  JPP_bundleImageNamed(@"video_letterbox_touch", libraryBundle);
	
	[control setFullscreenImage:videoFullscreenButtonImage forState:UIControlStateNormal];
	[control setFullscreenImage:videoFullscreenButtonSelectedImage forState:UIControlStateSelected];
	
	[control setInlineImage:videoInlineButtonImage forState:UIControlStateNormal];
	[control setInlineImage:videoInlineButtonSelectedImage forState:UIControlStateNormal];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
		[self JPPFullscreenToggleCommonInit];
    }
    return self;
}

- (void)JPPFullscreenToggleCommonInit
{
	[self addSubview:self.fullScreenButton];
	[self.fullScreenButton sizeToFit];
	self.frame = self.fullScreenButton.frame;
}

- (NSMutableDictionary *)controlImages
{
	if(_controlImages == nil)
	{
		_controlImages = [[NSMutableDictionary alloc] init];
	}
	return _controlImages;
}

- (UIButton *)fullScreenButton
{
	if(_fullScreenButton == nil)
	{
		_fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_fullScreenButton addTarget:self action:@selector(toggleFullscreen:) forControlEvents:UIControlEventTouchUpInside];
	}
	return _fullScreenButton;
}

- (void)setFullscreenImage:(UIImage *)image forState:(UIControlState)state
{
	[self setImage:image forKey:kFullScreenImageSet controlState:state];
	[self setupButtonForFullscreenState:[self.avPlayerController isFullscreen]];
}

- (void)setInlineImage:(UIImage *)image forState:(UIControlState)state
{
	[self setImage:image forKey:kInlineImageSet controlState:state];
	[self setupButtonForFullscreenState:[self.avPlayerController isFullscreen]];
}

- (JPPVideoPlayerControllerEventMask)supportedEvents
{
	return JPPVideoPlayerControllerEventMaskDidEnterFullscreen | JPPVideoPlayerControllerEventMaskDidExitFullscreen;
}

- (void)playerController:(JPPVideoPlayerController *)player eventOccurred:(JPPVideoPlayerControllerEvent)event
{
	if(event == JPPVideoPlayerControllerEventDidEnterFullscreen || event == JPPVideoPlayerControllerEventDidExitFullscreen)
	{
		[self setupButtonForFullscreenState:[self.avPlayerController isFullscreen]];
	}
}

- (void)toggleFullscreen:(id)sender
{
	BOOL isFullScreen = [self.avPlayerController isFullscreen];
	[self.avPlayerController setFullscreen:!isFullScreen animated:YES];
}

- (void)sizeToFit
{
	[self.fullScreenButton sizeToFit];
	self.frame = self.fullScreenButton.frame;
}

- (CGSize)sizeThatFits:(CGSize)size
{
	return [self.fullScreenButton sizeThatFits:size];
}

- (void)setupButtonForFullscreenState:(BOOL)isFullscreen
{
	NSString *key = (isFullscreen ? kInlineImageSet : kFullScreenImageSet);
	[self applyImagesForKey:key];
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
		[self.fullScreenButton setImage:image forState:state];
	}];
}

@end
