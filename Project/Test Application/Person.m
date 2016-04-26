//
//  Person.m
//  pkDebugFramework
//
//  Created by Patrick Kladek on 18.04.16.
//  Copyright (c) 2016 Patrick Kladek. All rights reserved.
//

#import "Person.h"
#import "pkDebugFramework.h"


@implementation Person

- (NSString *)debugDescription
{
	pkDebugDescription *description = [[pkDebugDescription alloc] init];
//	[description addAllPropertiesFromObject:self];
	
	return [description descriptionForObject:self];
}

- (id)debugQuickLookObject
{
	pkDebugView *view = [pkDebugView debugViewWithAllPropertiesOfObject:self includeSubclasses:YES];
	
	return view;
}

@end
