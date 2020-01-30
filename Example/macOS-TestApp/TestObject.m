//
//  TestObject.m
//  CocoaDebugFramework
//
//  Created by Patrick Kladek on 04.08.15.
//  Copyright (c) 2015 Patrick Kladek. All rights reserved.
//

#import "TestObject.h"
#import <CocoaDebugKit/CocoaDebugKit.h>

@implementation TestObject

- (NSString *)debugDescription
{
	return [[CocoaDebugDescription debugDescriptionForObject:self] stringRepresentation];
}

- (id)debugQuickLookObject
{
	return [CocoaDebugView debugViewWithAllPropertiesOfObject:self includeSuperclasses:YES];
}

@end
