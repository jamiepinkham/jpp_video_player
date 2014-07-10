//
//  JPPTransportControls.m
//  JPPVideoPlayerTester
//
//  Created by Jamie Pinkham on 8/28/13.
//  Copyright (c) 2013 Bottle Rocket. All rights reserved.
//

#import "JPPPlaybackControlsBar.h"
#import "JPPVideoPlayerFunctions.h"
#import "JPPPlaybackControl.h"

@interface JPPPlaybackControlsBar ()
{

	BOOL _needsControlUpdates;
    BOOL _videoIsLoading;
	
	NSArray *_toolbarControlItems;

}

@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) NSMutableArray *controls;
@property (nonatomic, strong) id stateChangeObserver;
@property (nonatomic, strong) id loadStateChangeObserver;

@end

@implementation JPPPlaybackControlsBar

+ (void)initialize
{
	JPPPlaybackControlsBar *appearance = [self appearance];
	
	[appearance setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.6f]];
	
	//toolbar setup
	
	[[UIToolbar appearanceWhenContainedIn:self, nil] setBackgroundImage:JPP_imageForColor([UIColor clearColor]) forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		[self commonInit];
	}
	return self;
}

- (void)commonInit
{
	_backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
	_backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[self addSubview:_backgroundImageView];
	
	_toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
	_toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[self addSubview:_toolbar];
	//	[_toolbar sizeToFit];
	
	_shouldShowLoadingIndicator = YES;
	
	_videoIsLoading = YES;
	
	_loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	_loadingView.hidden = YES;
	[self addSubview:_loadingView];
	
	_controls = [[NSMutableArray alloc] init];
//	[self startLoadingState];
	
	
//	_shouldShowPopoverWhileScrubbing = YES;
}

- (void)dealloc
{
	[self removeObservers];
}

- (void)removeObservers
{
	if(self.loadStateChangeObserver)
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self.loadStateChangeObserver];
	}
}

- (void)setPlayer:(JPPVideoPlayerController *)player
{
	[self removeObservers];
	[super setPlayer:player];
	
	if(self.player)
	{
		if(self.shouldShowLoadingIndicator)
		{
			self.loadStateChangeObserver = [[NSNotificationCenter defaultCenter] addObserverForName:JPPVideoPlayerLoadStateDidChangeNotification object:self.player queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
				JPPVideoPlayerController *controller = [note object];
				if([controller loadState] == JPPVideoLoadStatePlayable)
				{
					[self endLoadingState];
				}
				else
				{
					[self startLoadingState];
				}
			}];
			//add load state notification handler
		}
		
	}
}

#pragma mark - controls

- (void)setPlaybackControls:(NSArray *)controls
{
	[super setPlaybackControls:controls];
	[self setNeedsControlsUpdate];
}

- (void)addPlaybackControl:(UIView<JPPPlaybackControl> *)playbackControl
{
	[super addPlaybackControl:playbackControl];
	[self setNeedsControlsUpdate];
}

- (void)setNeedsControlsUpdate
{
	_needsControlUpdates = YES;
	_toolbarControlItems = nil;
    self.toolbar.items = nil;
	[self setNeedsLayout];
}

- (void)updateControlsIfNeeded
{
	if (_needsControlUpdates)
	{
		NSArray *toolbarItems = [self toolbarControlItems];
		
		if (![toolbarItems isEqualToArray:self.toolbar.items])
		{
			[self.toolbar setItems:toolbarItems animated:YES];
		}
		
		_needsControlUpdates = NO;
	}
}

- (NSArray *)toolbarControlItems
{
	if (!_toolbarControlItems)
	{
		NSMutableArray *items = [NSMutableArray array];
		
		UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
		
		NSArray *controls = [self.controls copy];
		for(UIView<JPPPlaybackControl> *playbackControl in controls)
		{
			[playbackControl sizeToFit];
			CGFloat width = [playbackControl toolbarWidth];
			[items addObject:flexibleSpace];
			UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:playbackControl];
			if(width > 0)
			{
				item.width = width;
			}
			[items addObject:item];
			[items addObject:flexibleSpace];
		}
				
		_toolbarControlItems = items;
	}
	
	return _toolbarControlItems;
}

#pragma mark - Appearance Settings

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
	_backgroundImage = backgroundImage;
	[_toolbar setBackgroundImage:backgroundImage forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
	self.backgroundImageView.image = backgroundImage;
}
#pragma mark - UIView

- (void)layoutSubviews
{
	[super layoutSubviews];
	[self updateControlsIfNeeded];
	if(_videoIsLoading && self.shouldShowLoadingIndicator)
	{
		[self startLoadingState];
	}
	else if(!_videoIsLoading && self.shouldShowLoadingIndicator)
	{
		[self endLoadingState];
	}
	
}

#pragma mark - load state

- (void)startLoadingState
{
	if(_videoIsLoading && self.shouldShowLoadingIndicator)
	{
		self.toolbar.alpha = 0.0f;
		self.loadingView.hidden = NO;
		[self.loadingView startAnimating];
		self.loadingView.center = [self convertPoint:self.toolbar.center fromView:self.toolbar];
		
		_videoIsLoading = YES;
	}
}

- (void)endLoadingState
{
	if(_videoIsLoading && self.shouldShowLoadingIndicator)
	{
		
		[UIView animateWithDuration:1.0f animations:^{
			self.loadingView.alpha = 0.0f;
			self.toolbar.alpha = 1.0f;

		} completion:^(BOOL finished) {

		}];
		
		_videoIsLoading = NO;
	}
}




@end
