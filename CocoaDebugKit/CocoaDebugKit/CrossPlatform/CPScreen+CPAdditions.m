//
//  CPScreen+CPAdditions.m
//  CocoaDebugKit
//
//  Created by Patrick Kladek on 20.05.17.
//  Copyright (c) 2017 Patrick Kladek. All rights reserved.
//

#import "CPScreen+CPAdditions.h"

#if TARGET_OS_IPHONE
@implementation UIScreen (CPAdditions)
#else
@implementation NSScreen (CPAdditions)
#endif

- (CGFloat)cp_scale
{
#if TARGET_OS_IPHONE
	return [self scale];
#else
	return [self backingScaleFactor];
#endif
}

@end
