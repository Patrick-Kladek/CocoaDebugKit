//
//  CPView+CPAdditions.h
//  CocoaDebugKit
//
//  Created by Patrick Kladek on 20.05.17.
//  Copyright (c) 2017 Patrick Kladek. All rights reserved.
//

#import "CrossPlatformDefinitions.h"

#if TARGET_OS_IPHONE
	@interface UIView (CPAdditions)

	@property (nonatomic) NSString *identifier;
#else
	@interface NSView (CPAdditions)
#endif

- (void)cp_update;

- (void)cp_setWantsLayer:(BOOL)useLayer;

@end
