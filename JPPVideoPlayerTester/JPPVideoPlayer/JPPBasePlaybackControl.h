//
//  JPPBasePlaybackControl.h
//  JPPVideoPlayerTester
//
//  Created by Jamie Pinkham on 9/6/13.
//  Copyright (c) 2013 Bottle Rocket. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPPPlaybackControl.h"

@class JPPVideoPlayerController;

@interface JPPBasePlaybackControl : UIView <JPPPlaybackControl>

@property (nonatomic, assign) CGFloat toolbarWidth;
@property (nonatomic, weak) JPPVideoPlayerController *avPlayerController;

@end
