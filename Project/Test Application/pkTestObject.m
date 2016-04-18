//
//  pkTestObject.m
//  pkDebugFramework
//
//  Created by Patrick Kladek on 04.08.15.
//  Copyright (c) 2015 Patrick Kladek. All rights reserved.
//

#import "pkTestObject.h"
#import "pkDebugFramework.h"

@implementation pkTestObject

- (id)debugQuickLookObject
{
	// option 1
	pkDebugView *view = [pkDebugView debugViewWithAllPropertiesOfObject:self];
	
	// or
//	pkDebugView *view = [[pkDebugView alloc] init];
//	[view addAllPropertiesFromObject:self];
	
	
	
	
	// option 2
//	pkDebugView *view = [pkDebugView debugViewWithProperties:@"name, image, set" ofObject:self];
	
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
