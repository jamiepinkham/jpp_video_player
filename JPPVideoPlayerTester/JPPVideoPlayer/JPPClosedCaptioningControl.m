//
//  JPPClosedCaptioningControl.m
//  JPPVideoPlayerTester
//
//  Created by Jamie Pinkham on 9/10/13.
//  Copyright (c) 2013 Bottle Rocket. All rights reserved.
//

#import "JPPClosedCaptioningControl.h"
#import "JPPVideoPlayerController.h"
#import "JPPVideoPlayerFunctions.h"

@interface JPPClosedCaptioningControl ()

@property (nonatomic, strong) UIButton *closedCaptioningButton;

@end

@implementation JPPClosedCaptioningControl

+ (void)initialize
{
	JPPClosedCaptioningControl *control = [self appearance];
	NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"JPPVideoPlayerResources" withExtension:@"bundle"];
	
	if(bundleURL == nil)
	{
		NSLog(@"bundle url is nil, did you forget to copy the resource bundle? falling back to the main bundle");
		bundleURL = [[NSBundle mainBundle] bundleURL];
	}
	
	NSBundle *libraryBundle = [NSBundle bundleWithURL:bundleURL];
	
	UIImage *ccImage = JPP_bundleImageNamed(@"video_cc", libraryBundle);
	UIImage *ccHighlightImage = JPP_bundleImageNamed(@"video_cc_touch", libraryBundle);
	UIImage *ccOnImage = JPP_bundleImageNamed(@"video_cc_on", libraryBundle);
	
	[control setClosedCaptionImage:ccImage forState:UIControlStateNormal];
	[control setClosedCaptionImage:ccHighlightImage forState:UIControlStateHighlighted];
	[control setClosedCaptionImage:ccOnImage forState:UIControlStateSelected];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
		[self JPPClosedCaptioningButtonCommonInit];
    }
    return self;
}

-(void)JPPClosedCaptioningButtonCommonInit
{
	[self addSubview:self.closedCaptioningButton];
	[self.closedCaptioningButton sizeToFit];
	self.frame = self.closedCaptioningButton.frame;
}

- (JPPVideoPlayerControllerEventMask)supportedEvents
{
	return JPPVideoPlayerControllerEventMaskNowPlayingChanged;
}

- (UIButton *)closedCaptioningButton
{
	if (_closedCaptioningButton == nil)
	{
		_closedCaptioningButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_closedCaptioningButton addTarget:self action:@selector(toggleClosedCaption) forControlEvents:UIControlEventTouchUpInside];
	}
	return _closedCaptioningButton;
}

- (void)setClosedCaptionImage:(UIImage *)image forState:(UIControlState)state
{
	[self.closedCaptioningButton setImage:image forState:state];
}

- (void)setAvPlayerController:(JPPVideoPlayerController *)avPlayerController
{
	[super setAvPlayerController:avPlayerController];
	self.closedCaptioningButton.enabled = self.avPlayerController.closedCaptioningAvailable;
}

- (void)playerController:(JPPVideoPlayerController *)player eventOccurred:(JPPVideoPlayerControllerEvent)event
{
	if(event == JPPVideoPlayerControllerEventNowPlayingChanged)
	{
		self.closedCaptioningButton.enabled = self.avPlayerController.closedCaptioningAvailable;
	}
}

- (CGSize)sizeThatFits:(CGSize)size
{
	return [self.closedCaptioningButton sizeThatFits:size];
}

- (void)sizeToFit
{
	[self.closedCaptioningButton sizeToFit];
	self.frame = self.closedCaptioningButton.frame;
}

- (void)toggleClosedCaption
{
	JPPVideoPlayerClosedCaptioningMode mode = self.avPlayerController.closedCaptioningMode;
	
	// Resolve the default mode
	// Mode is going to be toggled, so mode should reflect the current state of things
	if (mode == JPPVideoPlayerClosedCaptioningDefault)
		mode = UIAccessibilityIsClosedCaptioningEnabled() ? JPPVideoPlayerClosedCaptioningOn : JPPVideoPlayerClosedCaptioningOff;
	
	switch (mode) {
		case JPPVideoPlayerClosedCaptioningOff:
			mode = JPPVideoPlayerClosedCaptioningOn;
			break;
		case JPPVideoPlayerClosedCaptioningOn:
			mode = JPPVideoPlayerClosedCaptioningOff;
			break;
		default:
			mode = JPPVideoPlayerClosedCaptioningDefault;
			break;
	}
	
	self.avPlayerController.closedCaptioningMode = mode;
	
	[self updateClosedCaptionButtonForMode:mode];
}

- (void)updateClosedCaptionButtonForMode:(JPPVideoPlayerClosedCaptioningMode)mode
{
	self.closedCaptioningButton.highlighted = NO;
	
	BOOL shouldBeSelected = [self.avPlayerController shouldEnableClosedCaptioningForMode:mode];
	self.closedCaptioningButton.selected = shouldBeSelected;
}

@end
