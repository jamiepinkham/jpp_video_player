//
//  JPPControlContainer.m
//  JPPVideoPlayerTester
//
//  Created by Jamie Pinkham on 9/6/13.
//  Copyright (c) 2013 Jamie Pinkham. All rights reserved.
//

#import "JPPControlContainer.h"
#import "JPPVideoPlayerController.h"
#import "JPPPlaybackControl.h"

@interface JPPControlContainer ()

@property (nonatomic, strong) id stateChangeObserver;
@property (nonatomic, strong) NSMutableArray *controls;

@end

@implementation JPPControlContainer

- (instancetype)initWithPlayer:(JPPVideoPlayerController *)player
{
	self = [self initWithFrame:CGRectZero];
    if (self)
    {
        [self setPlayer:player];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
		[self JPPControlContainerCommonInit];
    }
    return self;
}

- (void)JPPControlContainerCommonInit
{
	self.clipsToBounds = YES;
}

- (void)dealloc
{
	[self removeObservers];
}

- (void)removeObservers
{
	if(self.stateChangeObserver)
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self.stateChangeObserver];
	}
}

- (void)setPlayer:(JPPVideoPlayerController *)player
{
	[self removeObservers];
	if(_player != player)
	{
		_player = player;
		self.stateChangeObserver = [[NSNotificationCenter defaultCenter] addObserverForName:JPPVideoPlayerEventOccurredNotification object:_player queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
			
			NSDictionary *userInfo = [note userInfo];
			JPPVideoPlayerControllerEvent event = [userInfo[JPPVideoPlayerEventOccurredUserInfoKey] integerValue];
			NSArray *controls = [self.controls copy];
            
			for(id<JPPPlaybackControl> control in controls)
			{
				JPPVideoPlayerControllerEventMask mask = 1 << event;
				if(((mask) & [control supportedEvents]))
				{
					[control playerController:[note object] eventOccurred:event];
				}
			}
		}];
	}
}

- (void)setPlaybackControls:(NSArray *)controls
{
	self.controls = [controls mutableCopy];
	[self.controls makeObjectsPerformSelector:@selector(setAvPlayerController:) withObject:self.player];
}

-(void)addPlaybackControl:(UIView<JPPPlaybackControl> *)playbackControl
{
	[playbackControl setAvPlayerController:self.player];
	[self.controls addObject:playbackControl];
}

- (void)layoutSubviews
{
	for(UIView<JPPPlaybackControl> *control in self.controls)
	{
		[control removeFromSuperview];
		[self addSubview:control];
	}
}

@end
