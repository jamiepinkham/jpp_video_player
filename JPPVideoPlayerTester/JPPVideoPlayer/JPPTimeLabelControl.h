//
//  JPPTimeLabelControl.h
//  JPPVideoPlayerTester
//
//  Created by Jamie Pinkham on 9/6/13.
//  Copyright (c) 2013 Bottle Rocket. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPPBasePlaybackControl.h"

typedef NSString *(^JPPTimeLabelControlTimeFormatter)(NSTimeInterval timeInterval);

@interface JPPTimeLabelControl : JPPBasePlaybackControl

@property (nonatomic, copy) JPPTimeLabelControlTimeFormatter currentPlaybackTimeFormatter;
@property (nonatomic, copy) JPPTimeLabelControlTimeFormatter durationTimeFormatter;

//TODO
@property (nonatomic, strong) NSDictionary *textAttributes;

@end
