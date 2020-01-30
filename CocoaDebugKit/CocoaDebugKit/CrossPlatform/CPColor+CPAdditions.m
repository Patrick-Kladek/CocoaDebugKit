//
//  CPColor+CPAdditions.m
//  CocoaDebugKit
//
//  Created by Patrick Kladek on 20.05.17.
//  Copyright (c) 2017 Patrick Kladek. All rights reserved.
//

#import "CPColor+CPAdditions.h"

#if TARGET_OS_IPHONE
	@implementation UIColor (CPAdditions)
#else
	@implementation NSColor (CPAdditions)
#endif

- (CGFloat)cp_redComponent
{
#if TARGET_OS_IPHONE
	CGFloat red,green,blue,alpha;
	[self getRed:&red green:&green blue:&blue alpha:&alpha];
	return red;
#else
	return [self redComponent];
#endif
}

- (CGFloat)cp_greenComponent
{
#if TARGET_OS_IPHONE
	CGFloat red,green,blue,alpha;
	[self getRed:&red green:&green blue:&blue alpha:&alpha];
	return green;
#else
	return [self greenComponent];
#endif
}

- (CGFloat)cp_blueComponent
{
#if TARGET_OS_IPHONE
	CGFloat red,green,blue,alpha;
	[self getRed:&red green:&green blue:&blue alpha:&alpha];
	return blue;
#else
	return [self blueComponent];
#endif
}

- (CGFloat)cp_alphaComponent
{
#if TARGET_OS_IPHONE
	CGFloat red,green,blue,alpha;
	[self getRed:&red green:&green blue:&blue alpha:&alpha];
	return alpha;
#else
	return [self alphaComponent];
#endif
}


@end
