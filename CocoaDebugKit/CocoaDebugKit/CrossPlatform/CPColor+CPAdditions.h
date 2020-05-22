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

@property (nonatomic, readonly) CGFloat cp_redComponent;
@property (nonatomic, readonly) CGFloat cp_greenComponent;
@property (nonatomic, readonly) CGFloat cp_blueComponent;
@property (nonatomic, readonly) CGFloat cp_alphaComponent;

@end
