//
//  JPPSkipBackControl.m
//  JPPVideoPlayerTester
//
//  Created by Jamie Pinkham on 9/9/13.
//  Copyright (c) 2013 Jamie Pinkham. All rights reserved.
//

#import "JPPSkipBackControl.h"
#import "JPPVideoPlayer/JPPVideoPlayerController.h"

@interface JPPSkipBackControl ()


@property (nonatomic, strong) UIButton *skipBackButton;

@end

@implementation JPPSkipBackControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self JPPSkipBackControlCommonInit];
    }
    return self;
}

-(JPPVideoPlayerControllerEventMask)supportedEvents
{
	return JPPVideoPlayerControllerEventMaskPlaybackTimeChanged;
	
}

- (void)playerController:(JPPVideoPlayerController *)player eventOccurred:(JPPVideoPlayerControllerEvent)event
{
	if(event == JPPVideoPlayerControllerEventPlaybackTimeChanged)
	{
		self.skipBackButton.enabled = ([player currentPlaybackTime] - self.skipBackSeconds) > 0;
	}
}

- (void)JPPSkipBackControlCommonInit
{
	self.skipBackSeconds = 1;
	self.skipBackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[self.skipBackButton setTitle:@"SB" forState:UIControlStateNormal];
	self.skipBackButton.enabled = NO;
	[self.skipBackButton sizeToFit];
	[self.skipBackButton addTarget:self action:@selector(skipBackAction:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:self.skipBackButton];
	self.frame = self.skipBackButton.frame;
}

- (void)skipBackAction:(id)sender
{
	NSTimeInterval toSeekTo = ([self.avPlayerController currentPlaybackTime] - self.skipBackSeconds);
	[self.avPlayerController setCurrentPlaybackTime:toSeekTo];
}

- (void)sizeToFit
{
	[self.skipBackButton sizeToFit];
	self.frame = self.skipBackButton.frame;
}

- (CGSize)sizeThatFits:(CGSize)size
{
	return [self.skipBackButton sizeThatFits:size];
}


@end
