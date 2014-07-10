//
//  JPPAVPlayerView.h
//  JPPVideoPlayerTester
//
//  Created by Jamie Pinkham on 8/15/13.
//  Copyright (c) 2013 Jamie Pinkham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@protocol JPPVideoPlayerViewDelegate;

@interface JPPVideoPlayerView : UIView
@property (nonatomic, weak) id<JPPVideoPlayerViewDelegate> delegate;
@property (nonatomic, strong) AVPlayer *player;

- (AVPlayerLayer *)playerLayer;
@end

@protocol JPPVideoPlayerViewDelegate <NSObject>

- (void)playerViewWillLayoutSubviews:(JPPVideoPlayerView *)playerView;
- (void)playerViewDidLayoutSubviews:(JPPVideoPlayerView *)playerView;

@end
