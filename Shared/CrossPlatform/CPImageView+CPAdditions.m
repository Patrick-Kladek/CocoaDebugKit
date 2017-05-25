//
//  CPImageView+CPAdditions.m
//  CocoaDebugKit
//
//  Created by Patrick Kladek on 20.05.17.
//  Copyright (c) 2017 Patrick Kladek. All rights reserved.
//

#import "CPImageView+CPAdditions.h"

#if TARGET_OS_IPHONE
@implementation UIImageView (CPAdditions)
#else
@implementation NSImageView (CPAdditions)
#endif

- (void)cp_setImageScaling:(CPImageScaling)scaling
{
#if TARGET_OS_IPHONE
	// Not availible on iOS
#else
	[self setImageScaling:(NSImageScaling)scaling];
#endif
}

- (void)cp_setEditable:(BOOL)editable
{
#if TARGET_OS_IPHONE
	// Not availible on iOS
#else
	[self setEditable:editable];
#endif
}

@end
