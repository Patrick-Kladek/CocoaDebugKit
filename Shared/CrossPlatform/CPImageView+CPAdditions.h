//
//  CPImageView+CPAdditions.h
//  CocoaDebugKit
//
//  Created by Patrick Kladek on 20.05.17.
//  Copyright (c) 2017 Patrick Kladek. All rights reserved.
//


#import "CrossPlatformDefinitions.h"

#if TARGET_OS_IPHONE
@interface UIImageView (CPAdditions)
#else
@interface NSImageView (CPAdditions)
#endif

- (void)cp_setImageScaling:(CPImageScaling)scaling;
- (void)cp_setEditable:(BOOL)editable;

@end
