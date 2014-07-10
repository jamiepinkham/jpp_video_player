//
//  JPPAirplayButton.m
//  JPPVideoPlayerTester
//
//  Created by Jamie Pinkham on 9/6/13.
//  Copyright (c) 2013 Bottle Rocket. All rights reserved.
//

#import "JPPAirplayControl.h"
#import "JPPVideoPlayerController.h"

@interface JPPAirplayControl ()

@property (nonatomic, strong) MPVolumeView *volumeView;

@end

@implementation JPPAirplayControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
		[self JPPAirplayCommonInit];
        // Initialization code
    }
    return self;
}

- (void)JPPAirplayCommonInit
{
	_volumeView = [[MPVolumeView alloc] init];
	_volumeView.showsVolumeSlider = NO;
	_volumeView.showsRouteButton = YES;
	[_volumeView sizeToFit];
	[self addSubview:_volumeView];
    
	self.backgroundColor = [UIColor clearColor];
	self.frame = _volumeView.frame;
}

@end
