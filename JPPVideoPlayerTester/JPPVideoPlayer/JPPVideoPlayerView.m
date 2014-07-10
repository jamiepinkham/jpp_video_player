//
//  JPPAVPlayerView.m
//  JPPVideoPlayerTester
//
//  Created by Jamie Pinkham on 8/15/13.
//  Copyright (c) 2013 Jamie Pinkham. All rights reserved.
//

#import "JPPVideoPlayerView.h"

@implementation JPPVideoPlayerView

+ (Class)layerClass
{
	return [AVPlayerLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame player:nil];
}

- (instancetype)initWithFrame:(CGRect)frame player:(AVPlayer *)player
{
	self = [super initWithFrame:frame];
	if (self)
	{
		[[self playerLayer] setPlayer:player];
		self.backgroundColor = [UIColor whiteColor];
		self.clipsToBounds = YES;
	}
	return self;
}


-(AVPlayerLayer *)playerLayer
{
	return (AVPlayerLayer *)[self layer];
}

- (void)setPlayer:(AVPlayer *)player
{
	[[self playerLayer] setPlayer:player];
}

-(AVPlayer *)player
{
	return [[self playerLayer] player];
}

- (void)layoutSubviews
{
	if ([self.delegate respondsToSelector:@selector(playerViewWillLayoutSubviews:)])
		[self.delegate playerViewWillLayoutSubviews:self];
	
	[super layoutSubviews];
	
	if ([self.delegate respondsToSelector:@selector(playerViewDidLayoutSubviews:)])
		[self.delegate playerViewDidLayoutSubviews:self];
}

@end
