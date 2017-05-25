//
//  CPColor+CPAdditions.h
//  CocoaDebugKit
//
//  Created by Patrick Kladek on 20.05.17.
//  Copyright (c) 2017 Patrick Kladek. All rights reserved.
//


#import "CrossPlatformDefinitions.h"

#if TARGET_OS_IPHONE
	@interface UIColor (CPAdditions)
#else
	@interface NSColor (CPAdditions)
#endif

- (CGFloat)cp_redComponent;
- (CGFloat)cp_greenComponent;
- (CGFloat)cp_blueComponent;
- (CGFloat)cp_alphaComponent;

@end
