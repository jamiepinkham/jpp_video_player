//
//  JPPBasePlaybackControl.m
//  JPPVideoPlayerTester
//
//  Created by Jamie Pinkham on 9/6/13.
//  Copyright (c) 2013 Bottle Rocket. All rights reserved.
//

#import "JPPBasePlaybackControl.h"
#import "JPPVideoPlayerTypes.h"

@implementation JPPBasePlaybackControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
    }
    return self;
}

- (JPPVideoPlayerControllerEventMask)supportedEvents
{
	return JPPVideoPlayerControllerEventMaskNone;
}

-  (void)playerController:(JPPVideoPlayerController *)player eventOccurred:(JPPVideoPlayerControllerEvent)event
{
	
}

@end
