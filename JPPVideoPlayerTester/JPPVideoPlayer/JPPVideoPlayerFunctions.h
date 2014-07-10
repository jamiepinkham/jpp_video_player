//
//  JPPAVPlayerFunctions.h
//  JPPVideoPlayerTester
//
//  Created by Jamie Pinkham on 8/28/13.
//  Copyright (c) 2013 Bottle Rocket. All rights reserved.
//

#ifndef JPPVideoPlayerTester_JPPAVPlayerFunctions_h
#define JPPVideoPlayerTester_JPPAVPlayerFunctions_h

#import <Foundation/Foundation.h>

static inline UIImage* JPP_imageForColorWithSize(UIColor *color, CGSize size)
{
	UIGraphicsBeginImageContext(size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
	CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}

static inline UIImage* JPP_imageForColor(UIColor *color)
{
	return JPP_imageForColorWithSize(color, CGSizeMake(1, 1));
}

static inline UIImage* JPP_bundleImageNamed(NSString *imageName, NSBundle *bundle)
{
	
	NSString *imagePath = [bundle pathForResource:imageName ofType:@"png"];
	if(imagePath)
	{
		return [UIImage imageWithContentsOfFile:imagePath];
	}
	return nil;
}

#endif
