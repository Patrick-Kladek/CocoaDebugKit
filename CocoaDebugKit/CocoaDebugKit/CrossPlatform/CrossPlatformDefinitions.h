//
//  CrossPlatformDefinitions.h
//  CocoaDebugKit
//
//  Created by Patrick Kladek on 20.05.17.
//  Copyright (c) 2017 Patrick Kladek. All rights reserved.
//

#include <TargetConditionals.h>

#ifndef CocoaDebugKit_CrossPlatformDefinitions_h
#define CocoaDebugKit_CrossPlatformDefinitions_h

	#if TARGET_OS_IPHONE

		#import <UIKit/UIKit.h>
		#import <CocoaDebugKit/CocoaPropertyLine.h>
		typedef UIView	CPView;
		typedef UIColor	CPColor;
		typedef UIFont	CPFont;
		typedef UIImage	CPImage;
		typedef UILabel	CPTextField;
		typedef UIImageView CPImageView;
		typedef UIScreen CPScreen;

		typedef CGPoint CPPoint;
		typedef CGSize	CPSize;
		typedef CGRect	CPRect;

		// iOS doesn´t have Image scaling
		typedef NS_ENUM(NSUInteger, CPImageScaling) {
			CPImageScaleProportionallyDown = 0,
			CPImageScaleAxesIndependently = 0,
			CPImageScaleNone = 0,
			CPImageScaleProportionallyUpOrDown = 0
		};
		typedef NS_ENUM(NSUInteger, CPTextAlignment) {
			CPAlignmentLeft = NSTextAlignmentLeft,
			CPAlignmentCenter = NSTextAlignmentCenter,
			CPAlignmentRight = NSTextAlignmentRight,
			CPAlignmentJustified = NSTextAlignmentJustified,
			CPAlignmentNatural = NSTextAlignmentNatural
		};


		#define CPMakeSize(width, height) CGSizeMake(width, height)
		#define CPMakeRect(x, y, w, h) CGRectMake(x, y, w, h)
		#define CPMakePoint(x, y) CGPointMake(x, y)
		#define CPSizeFromString(string) CGSizeFromString(string)

	#else

		#import <Cocoa/Cocoa.h>
		#import <QuartzCore/QuartzCore.h>
		#import <CocoaDebugKit/CocoaPropertyLine.h>
		typedef NSView	CPView;
		typedef NSColor	CPColor;
		typedef NSFont	CPFont;
		typedef NSImage	CPImage;
		typedef NSTextField	CPTextField;
		typedef NSImageView CPImageView;
		typedef NSScreen CPScreen;

		typedef NSPoint CPPoint;
		typedef NSSize	CPSize;
		typedef NSRect	CPRect;


		typedef NS_ENUM(NSUInteger, CPImageScaling) {
			CPImageScaleProportionallyDown = NSImageScaleProportionallyDown,
			CPImageScaleAxesIndependently = NSImageScaleAxesIndependently,
			CPImageScaleNone = NSImageScaleNone,
			CPImageScaleProportionallyUpOrDown = NSImageScaleProportionallyUpOrDown
		};
		typedef NS_ENUM(NSUInteger, CPTextAlignment) {
            CPAlignmentCenter = NSTextAlignmentCenter,
            CPAlignmentLeft = NSTextAlignmentLeft,
            CPAlignmentRight = NSTextAlignmentRight,
            CPAlignmentJustified = NSTextAlignmentJustified,
            CPAlignmentNatural = NSTextAlignmentNatural
		};



		#define CPMakeSize(width, height) NSMakeSize(width, height)
		#define CPMakeRect(x, y, w, h) NSMakeRect(x, y, w, h)
		#define CPMakePoint(x, y) NSMakePoint(x, y)

		#define CPSizeFromString(string) NSSizeFromString(string)
	#endif

#endif
