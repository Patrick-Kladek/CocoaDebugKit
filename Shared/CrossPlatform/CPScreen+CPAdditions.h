//
//  CPScreen+CPAdditions.h
//  CocoaDebugKit
//
//  Created by Patrick Kladek on 20.05.17.
//  Copyright (c) 2017 Patrick Kladek. All rights reserved.
//

#import "CrossPlatformDefinitions.h"

#if TARGET_OS_IPHONE
@interface UIScreen (CPAdditions)
#else
@interface NSScreen (CPAdditions)
#endif

@property (nonatomic, readonly) CGFloat cp_scale;

@end
