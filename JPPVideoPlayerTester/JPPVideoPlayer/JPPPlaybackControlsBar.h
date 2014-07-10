//
//  JPPTransportControls.h
//  JPPVideoPlayerTester
//
//  Created by Jamie Pinkham on 8/28/13.
//  Copyright (c) 2013 Bottle Rocket. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPPVideoPlayerController.h"
#import "JPPControlContainer.h"


@interface JPPPlaybackControlsBar : JPPControlContainer <UIAppearanceContainer>

@property (nonatomic, strong) UIImage *backgroundImage UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) BOOL shouldShowLoadingIndicator;

@end

