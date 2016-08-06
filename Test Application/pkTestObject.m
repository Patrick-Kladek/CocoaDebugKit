//
//  pkTestObject.m
//  pkDebugFramework
//
//  Created by Patrick Kladek on 04.08.15.
//  Copyright (c) 2015 Patrick Kladek. All rights reserved.
//

#import "pkTestObject.h"
#import <pkDebugFramework/pkDebugFramework.h>

@implementation pkTestObject

- (NSString *)debugDescription
{
	pkDebugDescription *description = [[pkDebugDescription alloc] init];
	
	return [description descriptionForObject:self];
}

- (id)debugQuickLookObject
{
	// option 1
	pkDebugView *view = [pkDebugView debugViewWithAllPropertiesOfObject:self includeSuperclasses:YES];
	
	// or
//	pkDebugView *view = [[pkDebugView alloc] init];
//	[view setFrameColor:[NSColor purpleColor]];
//	[view addAllPropertiesFromObject:self includeSubclasses:YES];
	
	
	
	
	// option 2
//	pkDebugView *view = [pkDebugView debugViewWithProperties:@"_name, _image, _url" ofObject:self];
	
	// or
//	pkDebugView *view = [pkDebugView debugView];
//	[view addProperties:@"name, image" fromObject:self];
//	[view addProperties:@"object.name" fromObject:self];	// does not work
	
	
	// option 3
//	pkDebugView *view = [pkDebugView debugView];
//	[view addLineWithDescription:@"Name" string:_name];
	
	return view;
}

@end
