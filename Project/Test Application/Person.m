//
//  Person.m
//  pkDebugFramework
//
//  Created by Patrick Kladek on 18.04.16.
//  Copyright (c) 2016 Patrick Kladek. All rights reserved.
//

#import "Person.h"
#import <pkDebugFramework/pkDebugFramework.h>


@implementation Person

- (NSString *)debugDescription
{
	pkDebugDescription *description = [[pkDebugDescription alloc] init];
	
	return [description descriptionForObject:self];
}

- (id)debugQuickLookObject
{
	pkDebugView *view = [pkDebugView debugViewWithAllPropertiesOfObject:self includeSubclasses:YES];
	[view setFrameColor:[NSColor purpleColor]];
	
	return view;
}

@end
