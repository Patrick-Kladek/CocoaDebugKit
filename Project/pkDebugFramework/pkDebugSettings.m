//
//  pkDebugSettings.m
//  pkDebugFramework
//
//  Created by Patrick Kladek on 19.04.16.
//  Copyright (c) 2016 Patrick Kladek. All rights reserved.
//

#import "pkDebugSettings.h"


static NSColor *NSColorFromHexString(NSString *inColorString)
{
	NSColor *result = nil;
	unsigned colorCode = 0;
	unsigned char redByte, greenByte, blueByte, alphaByte;
	
	if (nil != inColorString)
	{
		NSScanner *scanner = [NSScanner scannerWithString:inColorString];
		(void) [scanner scanHexInt:&colorCode]; // ignore error
	}
	redByte = (unsigned char)(colorCode >> 24);
	greenByte = (unsigned char)(colorCode >> 16);
	blueByte = (unsigned char)(colorCode >> 8);
	alphaByte = (unsigned char)(colorCode);		// masks off high bits
	
	result = [NSColor colorWithCalibratedRed:(CGFloat)redByte / 0xff green:(CGFloat)greenByte / 0xff blue:(CGFloat)blueByte / 0xff alpha:(CGFloat)alphaByte / 0xff];
	return result;
}


@interface pkDebugSettings ()
{
	NSDictionary *settings;
}

@end



@implementation pkDebugSettings

+ (pkDebugSettings *)sharedSettings
{
	// structure used to test whether the block has completed or not
	static dispatch_once_t p = 0;
	
	// initialize sharedObject as nil (first call only)
	__strong static id _sharedObject = nil;
	
	// executes a block object once and only once for the lifetime of an application
	dispatch_once(&p, ^{
		_sharedObject = [[self alloc] init];
	});
	
	// returns the same object each time
	return _sharedObject;
}

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		_lineSpace				= 7;
		_highlightKeywords		= true;
		_highlightNumbers		= true;
		
		_textColor				= [NSColor blackColor];
		_textFont				= [NSFont fontWithName:@"Menlo" size:12];
		
		_keywordColor			= [NSColor colorWithCalibratedRed:0.592 green:0.000 blue:0.496 alpha:1.000];
		_keywordFont			= [NSFont fontWithName:@"Menlo" size:12];
		
		_numberColor			= [NSColor colorWithCalibratedRed:0.077 green:0.000 blue:0.766 alpha:1.000];
		_numberFont				= [NSFont fontWithName:@"Menlo" size:12];
		
		_propertyNameColor		= [NSColor blackColor];
		_propertyNameFont		= [NSFont fontWithName:@"Menlo" size:12];
		
		_titleColor				= [NSColor whiteColor];
		_titleFont				= [NSFont fontWithName:@"Menlo Bold" size:13];
		
		
		_frameColor				= [NSColor blueColor];
		_backgroundColor		= [NSColor whiteColor];
		_imageSize				= NSMakeSize(30, 30);
	}
	return self;
}

- (BOOL)loadSettings:(NSURL *)url
{
	_url = url;
	
	settings = [NSDictionary dictionaryWithContentsOfURL:_url];
	
	if (settings)
	{
		[self importSettings];
		return YES;
	}
	
	return NO;
}

- (BOOL)saveSettings:(NSURL *)url
{
	@throw @"not implemented";
	return NO;
}

- (void)importSettings
{
	if ([settings valueForKeyPath:@"keywords.highlight"]) {
		_highlightKeywords = [[settings valueForKeyPath:@"keywords.highlight"] boolValue];
	}
	
	if ([settings valueForKeyPath:@"keywords.color"]) {
		_keywordColor = NSColorFromHexString([settings valueForKeyPath:@"keywords.color"]);
	}
	
	if ([settings valueForKeyPath:@"keywords.font"] && [settings valueForKeyPath:@"keywords.size"]) {
		_keywordFont = [NSFont fontWithName:[settings valueForKeyPath:@"keywords.font"] size:[[settings valueForKeyPath:@"keywords.size"] integerValue]];
	}
	
	
	
	
	if ([settings valueForKeyPath:@"numbers.highlight"]) {
		_highlightNumbers = [[settings valueForKeyPath:@"numbers.highlight"] boolValue];
	}
	
	if ([settings valueForKeyPath:@"numbers.color"]) {
		_numberColor = NSColorFromHexString([settings valueForKeyPath:@"numbers.color"]);
	}
	
	if ([settings valueForKeyPath:@"numbers.font"] && [settings valueForKeyPath:@"numbers.size"]) {
		_numberFont = [NSFont fontWithName:[settings valueForKeyPath:@"numbers.font"] size:[[settings valueForKeyPath:@"numbers.size"] integerValue]];
	}
	
	
	
	
	
	if ([settings valueForKeyPath:@"text.color"]) {
		_textColor = NSColorFromHexString([settings valueForKeyPath:@"text.color"]);
	}
	
	if ([settings valueForKeyPath:@"text.font"] && [settings valueForKeyPath:@"text.size"]) {
		_textFont = [NSFont fontWithName:[settings valueForKeyPath:@"text.font"] size:[[settings valueForKeyPath:@"text.size"] integerValue]];
	}
	
	
	
	
	if ([settings valueForKeyPath:@"propertyName.color"]) {
		_propertyNameColor = NSColorFromHexString([settings valueForKeyPath:@"propertyName.color"]);
	}
	
	if ([settings valueForKeyPath:@"propertyName.font"] && [settings valueForKeyPath:@"propertyName.size"]) {
		_propertyNameFont = [NSFont fontWithName:[settings valueForKeyPath:@"propertyName.font"] size:[[settings valueForKeyPath:@"propertyName.size"] integerValue]];
	}
	
	
	
	if ([settings valueForKeyPath:@"title.color"]) {
		_titleColor = NSColorFromHexString([settings valueForKeyPath:@"title.color"]);
	}
	
	if ([settings valueForKeyPath:@"title.font"] && [settings valueForKeyPath:@"title.size"]) {
		_titleFont = [NSFont fontWithName:[settings valueForKeyPath:@"title.font"] size:[[settings valueForKeyPath:@"title.size"] integerValue]];
	}
	
	
	
	if ([settings valueForKeyPath:@"image.size"]) {
		_imageSize = NSSizeFromString([settings valueForKeyPath:@"image.size"]);
	}
	
	
	
	
	if ([settings valueForKeyPath:@"appearance.lineSpace"]) {
		_lineSpace = [[settings valueForKeyPath:@"appearance.lineSpace"] integerValue];
	}
	
	if ([settings valueForKeyPath:@"appearance.backgroundColor"]) {
		_backgroundColor = NSColorFromHexString([settings valueForKeyPath:@"appearance.backgroundColor"]);
	}
	
	if ([settings valueForKeyPath:@"appearance.frameColor"]) {
		_frameColor = NSColorFromHexString([settings valueForKeyPath:@"appearance.frameColor"]);
	}
}

@end
