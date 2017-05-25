//
//  NSObject+CPAdditions.m
//  CocoaDebugKit
//
//  Created by Patrick Kladek on 20.05.17.
//  Copyright (c) 2017 Patrick Kladek. All rights reserved.
//

#import "NSObject+CPAdditions.h"

@implementation NSObject (CPAdditions)

- (NSString *)cp_className
{
#if TARGET_OS_IPHONE
	return [NSString stringWithFormat:@"%@", [self class]];
#else
	return [self className];
#endif
}

@end
