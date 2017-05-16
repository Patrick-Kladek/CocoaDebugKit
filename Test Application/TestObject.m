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
	CocoaDebugDescription *description = [[CocoaDebugDescription alloc] init];
	
	return [description descriptionForObject:self];
}

- (id)debugQuickLookObject
{
	CocoaDebugView *view = [CocoaDebugView debugViewWithAllPropertiesOfObject:self includeSuperclasses:YES];
	
	return view;
}

@end
