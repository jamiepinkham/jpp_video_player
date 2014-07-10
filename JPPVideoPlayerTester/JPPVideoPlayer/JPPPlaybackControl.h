//
//  JPPPlaybackControl.h
//  JPPVideoPlayerTester
//
//  Created by Jamie Pinkham on 9/6/13.
//  Copyright (c) 2013 Jamie Pinkham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPPVideoPlayerTypes.h"

@class JPPVideoPlayerController;

@protocol JPPPlaybackControl <NSObject>

@property (nonatomic, assign) CGFloat toolbarWidth;
@property (nonatomic, weak) JPPVideoPlayerController *avPlayerController;
- (JPPVideoPlayerControllerEventMask)supportedEvents;
- (void)playerController:(JPPVideoPlayerController *)player eventOccurred:(JPPVideoPlayerControllerEvent)event;

@end

