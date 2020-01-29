//
//  CocoaPropertyLine.m
//  CocoaTouchDebugKit
//
//  Created by Patrick Kladek on 25.05.17.
//  Copyright (c) 2017 Patrick Kladek. All rights reserved.
//

#import "CocoaPropertyLine.h"


@implementation CocoaPropertyLine

+ (CocoaPropertyLine *)lineWithType:(NSString *)type name:(NSString *)name value:(NSString *)value
{
	return [[self alloc] initWithType:type name:name value:value];
}

- (instancetype)initWithType:(NSString *)type name:(NSString *)name value:(NSString *)value
{
	self = [super init];
	if (self) {
		_type = type;
		_name = name;
		_value = value;
	}
	return self;
}

@end
