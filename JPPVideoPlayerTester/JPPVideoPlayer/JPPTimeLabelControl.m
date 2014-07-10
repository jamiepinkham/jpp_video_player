//
//  JPPTimeLabelControl.m
//  JPPVideoPlayerTester
//
//  Created by Jamie Pinkham on 9/6/13.
//  Copyright (c) 2013 Bottle Rocket. All rights reserved.
//

#import "JPPTimeLabelControl.h"
#import "JPPVideoPlayerFunctions.h"
#import "JPPVideoPlayerController.h"

@interface JPPTimeLabelControl ()

@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *durationTimeLabel;

@end

@implementation JPPTimeLabelControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
		[self JPPTimeLabelControlCommonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		[self JPPTimeLabelControlCommonInit];
	}
	return self;
}

- (void)JPPTimeLabelControlCommonInit
{
	_currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_currentTimeLabel.backgroundColor = [UIColor clearColor];
	_currentTimeLabel.textColor = [UIColor whiteColor];
	_currentTimeLabel.textAlignment = NSTextAlignmentRight;
	
	_durationTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	_durationTimeLabel.backgroundColor = [UIColor clearColor];
	_durationTimeLabel.textColor = [UIColor whiteColor];
	_durationTimeLabel.textAlignment = NSTextAlignmentRight;
	
	[self addSubview:_currentTimeLabel];
	[self addSubview:_durationTimeLabel];
}

- (void)layoutSubviews
{
	[self.currentTimeLabel sizeToFit];
	[self.durationTimeLabel sizeToFit];
	self.durationTimeLabel.frame = CGRectMake(CGRectGetMaxX(self.currentTimeLabel.frame)+ 5.0f, 0, CGRectGetWidth(self.durationTimeLabel.frame), CGRectGetHeight(self.durationTimeLabel.frame));
	CGFloat width = CGRectGetWidth(self.currentTimeLabel.frame) + CGRectGetWidth(self.durationTimeLabel.frame) + 10.0f;
	CGFloat height = MAX(CGRectGetHeight(self.currentTimeLabel.frame), CGRectGetHeight(self.durationTimeLabel.frame));
	self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), width, height);
}

- (JPPVideoPlayerControllerEventMask)supportedEvents
{
	return JPPVideoPlayerControllerEventMaskDurationAvailable | JPPVideoPlayerControllerEventMaskPlaybackTimeChanged;
}

- (void)playerController:(JPPVideoPlayerController *)player eventOccurred:(JPPVideoPlayerControllerEvent)event
{
	if (event == JPPVideoPlayerControllerEventDurationAvailable)
	{
		if(self.durationTimeFormatter)
		{
			self.durationTimeLabel.text = self.durationTimeFormatter([player duration]);
		}
		else
		{
			self.durationTimeLabel.text = nil;
		}
	}
	else if (event == JPPVideoPlayerControllerEventPlaybackTimeChanged)
	{
		if(self.currentPlaybackTimeFormatter)
		{
			self.currentTimeLabel.text = self.currentPlaybackTimeFormatter([player currentPlaybackTime]);
		}
		else
		{
			self.currentTimeLabel.text = nil;
		}
	}
	[self setNeedsLayout];
}

@end
