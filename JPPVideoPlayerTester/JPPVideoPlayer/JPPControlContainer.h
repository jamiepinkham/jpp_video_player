//
//  JPPControlContainer.h
//  JPPVideoPlayerTester
//
//  Created by Jamie Pinkham on 9/6/13.
//  Copyright (c) 2013 Jamie Pinkham. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JPPVideoPlayerController;
@protocol JPPPlaybackControl;

@interface JPPControlContainer : UIView <UIAppearanceContainer>

- (void)setPlaybackControls:(NSArray *)controls;
- (void)addPlaybackControl:(UIView<JPPPlaybackControl> *)playbackControl;

@property (nonatomic, weak) JPPVideoPlayerController *player;

- (instancetype)initWithPlayer:(JPPVideoPlayerController *)player;

@end



