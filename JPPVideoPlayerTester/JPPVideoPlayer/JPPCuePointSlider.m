//
//  JPPCuePointSlider.m
//  JPPVideoPlayerTester
//
//  Created by Jamie Pinkham on 8/28/13.
//  Copyright (c) 2013 Bottle Rocket. All rights reserved.
//

#import "JPPCuePointSlider.h"
#import "JPPVideoPlayerFunctions.h"
#import "JPPVideoPlayerController.h"

@interface JPPCuePointSlider()
{
	UISlider *_backgroundSlider;	// We can't just insert arbitrary subviews into our own hierarchy, but we can make a background slider for
	NSMutableDictionary *_cueViews;
}
@end

@implementation JPPCuePointSlider
@synthesize cueViews = _cueViews;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
		[self JPPCuePointSliderCommonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		[self JPPCuePointSliderCommonInit];
	}
	return self;
}

- (JPPVideoPlayerControllerEventMask)supportedEvents
{
	return JPPVideoPlayerControllerEventMaskPlaybackTimeChanged | JPPVideoPlayerControllerEventMaskDurationAvailable;
}

- (void)playerController:(JPPVideoPlayerController *)player eventOccurred:(JPPVideoPlayerControllerEvent)event
{
	if (event == JPPVideoPlayerControllerEventPlaybackTimeChanged)
	{
		[self setValue:[player currentPlaybackTime]];
	}
	else if (event == JPPVideoPlayerControllerEventDurationAvailable)
	{
		[self setMaximumValue:[player duration]];
	}
}

- (CGSize)sizeThatFits:(CGSize)size
{
	return [_backgroundSlider sizeThatFits:size];
}

- (void)sizeToFit
{
	[_backgroundSlider sizeToFit];
	self.bounds = _backgroundSlider.frame;
}

- (void)JPPCuePointSliderCommonInit
{
	// Clear image, since setting nil will use defaults
	UIImage *clear = JPP_imageForColor([UIColor clearColor]);
	
	_backgroundSlider = [[UISlider alloc] initWithFrame:self.bounds];
	_backgroundSlider.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[_backgroundSlider setThumbImage:clear forState:UIControlStateNormal];
	_backgroundSlider.userInteractionEnabled = NO;
	[self addSubview:_backgroundSlider];
	[self sendSubviewToBack:_backgroundSlider];
	
	[super setMinimumTrackImage:clear forState:UIControlStateNormal];
	[super setMaximumTrackImage:clear forState:UIControlStateNormal];
	
	_cueViews = [[NSMutableDictionary alloc] init];
	
	NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"JPPVideoPlayerResources" withExtension:@"bundle"];
	
	if(bundleURL == nil)
	{
		NSLog(@"bundle url is nil, did you forget to copy the resource bundle? falling back to the main bundle");
		bundleURL = [[NSBundle mainBundle] bundleURL];
	}
	
	NSBundle *libraryBundle = [NSBundle bundleWithURL:bundleURL];
	
	UIEdgeInsets insets = UIEdgeInsetsMake(1.0f, 4.0f, 1.0f, 4.0f);
	
	UIImage *minTrackImage = JPP_bundleImageNamed(@"video_track_filled", libraryBundle);
	UIImage *maxTrackImage = JPP_bundleImageNamed(@"video_track_unfilled", libraryBundle);
	UIImage *scrubber = JPP_bundleImageNamed(@"thumb_scrubber", libraryBundle);
	
	[self setMinimumTrackImage:[minTrackImage resizableImageWithCapInsets:insets]  forState:UIControlStateNormal];
	
	[self setMaximumTrackImage:[maxTrackImage resizableImageWithCapInsets:insets] forState:UIControlStateNormal];
	
	[self setThumbImage:scrubber forState:UIControlStateNormal];
	
	[self addTarget:self action:@selector(didSeek) forControlEvents:UIControlEventValueChanged];
}

- (void)setFrame:(CGRect)frame
{
	[_backgroundSlider setFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
	[super setFrame:frame];
}

- (void)setMinimumTrackImage:(UIImage *)image forState:(UIControlState)state
{
	[_backgroundSlider setMinimumTrackImage:image forState:state];
}

- (void)setMaximumTrackImage:(UIImage *)image forState:(UIControlState)state
{
	[_backgroundSlider setMaximumTrackImage:image forState:state];
}

- (void)setThumbImage:(UIImage *)image forState:(UIControlState)state
{
	[super setThumbImage:image forState:state];
	
	// The background slider's thumb image needs to be the same size as our thumb image, otherwise
	// the background tracking will be calculated incorrectly and the filled portion will look wrong.
	UIImage *clear = JPP_imageForColorWithSize([UIColor clearColor], image.size);
	[_backgroundSlider setThumbImage:clear forState:state];
}

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
{
	// Have to convert rect to the background slider since we're 2 sliders
	rect = [_backgroundSlider trackRectForBounds:bounds];
	CGRect thumbRect = [super thumbRectForBounds:bounds trackRect:rect value:value];
	
	// Offset for any shadow
	thumbRect = CGRectOffset(thumbRect, self.thumbShadow.width, self.thumbShadow.height);
	
	return thumbRect;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	// Layout all the views for cuepoints
	[_cueViews enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, UIView *view, BOOL *stop) {
		float value = key.floatValue;
		view.frame = [self rectForCueView:view bounds:self.bounds trackRect:[self trackRectForBounds:self.bounds] value:value];
	}];
}

- (CGRect)rectForCueView:(UIView *)view bounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
{
	CGFloat midX =  (value - self.minimumValue) / self.maximumValue * CGRectGetWidth(rect);
	CGRect cueRect = CGRectMake(roundf(midX - CGRectGetWidth(view.bounds) / 2.0f) , roundf(CGRectGetMidY(rect) - CGRectGetHeight(view.bounds) / 2.0f), CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds));
	
	return cueRect;
}

#pragma mark - Cue Views

- (void)setCueViews:(NSDictionary *)cueViews
{
	if (cueViews == _cueViews)
		return;
	
	[_cueViews enumerateKeysAndObjectsUsingBlock:^(id key, UIView *view, BOOL *stop) {
		[view removeFromSuperview];
	}];
	
	[_cueViews removeAllObjects];
	[cueViews enumerateKeysAndObjectsUsingBlock:^(id key, UIView *view, BOOL *stop) {
		[self insertSubview:view aboveSubview:_backgroundSlider];
		[_cueViews setObject:view forKey:key];
	}];
	
	[self setNeedsLayout];
}

- (void)setCueView:(UIView *)cueView forValue:(NSNumber *)value
{
	if ([_cueViews objectForKey:value])
	{
		[self removeCueViewForvalue:value];
	}
	
	[_cueViews setObject:cueView forKey:value];
	[self insertSubview:cueView aboveSubview:_backgroundSlider];
	[self setNeedsLayout];
}

- (void)removeCueViewForvalue:(NSNumber *)value
{
	[[_cueViews objectForKey:value] removeFromSuperview];
	[_cueViews removeObjectForKey:value];
}

#pragma mark - Delegate methods

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	BOOL begin = [super beginTrackingWithTouch:touch withEvent:event];
	
	if (begin)
	{
		if ([self.delegate respondsToSelector:@selector(sliderTrackingDidBegin:)])
			[self.delegate sliderTrackingDidBegin:self];
	}
	
	return begin;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	if ([self.delegate respondsToSelector:@selector(sliderTrackingDidEnd:)])
		[self.delegate sliderTrackingDidEnd:self];
	
	[super endTrackingWithTouch:touch withEvent:event];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
	if ([self.delegate respondsToSelector:@selector(sliderTrackingDidCancel:)])
		[self.delegate sliderTrackingDidCancel:self];
	
	[super cancelTrackingWithEvent:event];
}

- (void)didSeek
{
	if ([self.delegate respondsToSelector:@selector(slider:didChangeValue:)])
		[self.delegate slider:self didChangeValue:self.value];
	
	[_backgroundSlider setValue:self.value];
}

- (void)setValue:(float)value
{
    if (!isnan(value))
    {
        [super setValue:value];
        [_backgroundSlider setValue:value];
    }
}

- (void)setMinimumValue:(float)minimumValue
{
    if (!isnan(minimumValue))
    {
        [super setMinimumValue:minimumValue];
        [_backgroundSlider setMinimumValue:minimumValue];
    }
}

- (void)setMaximumValue:(float)maximumValue
{
    if (!isnan(maximumValue))
    {
        [super setMaximumValue:maximumValue];
        [_backgroundSlider setMaximumValue:maximumValue];
    }
}

@end
