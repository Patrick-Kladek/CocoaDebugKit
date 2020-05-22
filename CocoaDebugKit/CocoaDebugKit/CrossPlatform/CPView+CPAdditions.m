//
//  CPView+CPAdditions.m
//  CocoaDebugKit
//
//  Created by Patrick Kladek on 20.05.17.
//  Copyright (c) 2017 Patrick Kladek. All rights reserved.
//

#import "CPView+CPAdditions.h"
@import ObjectiveC.runtime;


#if TARGET_OS_IPHONE
@implementation UIView (CPAdditions)
#else
@implementation NSView (CPAdditions)
#endif

#if TARGET_OS_IPHONE

- (void)setIdentifier:(NSString *)identifier
{
	objc_setAssociatedObject(self, @"identifier", identifier, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)identifier
{
	return objc_getAssociatedObject(self, @"identifier");
}

#endif

- (void)cp_update
{
#if TARGET_OS_IPHONE
	[self setNeedsDisplay];
#else
	[self setNeedsDisplay:YES];
    [self.layer setNeedsLayout];
#endif
}

- (void)cp_setWantsLayer:(BOOL)useLayer
{
#if TARGET_OS_IPHONE
	// iOS Views are always layer based
#else
	[self setWantsLayer:useLayer];
#endif
}


@end
