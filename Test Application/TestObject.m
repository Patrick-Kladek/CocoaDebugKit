//
//  TestObject.m
//  CocoaDebugFramework
//
//  Created by Patrick Kladek on 04.08.15.
//  Copyright (c) 2015 Patrick Kladek. All rights reserved.
//

#import "TestObject.h"
#import <CocoaDebugFramework/CocoaDebugFramework.h>

@implementation TestObject

- (NSString *)debugDescription
{
	CocoaDebugDescription *description = [[CocoaDebugDescription alloc] init];
	
	return [description descriptionForObject:self];
}

- (id)debugQuickLookObject
{
	// option 1
	CocoaDebugView *view = [CocoaDebugView debugViewWithAllPropertiesOfObject:self includeSuperclasses:YES];
	
	// or
//	CocoaDebugView *view = [[CocoaDebugView alloc] init];
//	[view setFrameColor:[NSColor purpleColor]];
//	[view addAllPropertiesFromObject:self includeSubclasses:YES];
	
	
	
	
	// option 2
//	CocoaDebugView *view = [CocoaDebugView debugViewWithProperties:@"_name, _image, _url" ofObject:self];
	
	// or
//	CocoaDebugView *view = [CocoaDebugView debugView];
//	[view addProperties:@"name, image" fromObject:self];
//	[view addProperties:@"object.name" fromObject:self];	// does not work
	
	
	// option 3
//	CocoaDebugView *view = [CocoaDebugView debugView];
//	[view addLineWithDescription:@"Name" string:_name];
	
	return view;
}

@end
