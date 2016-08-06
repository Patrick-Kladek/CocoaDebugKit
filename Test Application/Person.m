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

- (id)debugQuickLookObject
{
	pkDebugView *view = [pkDebugView debugViewWithAllPropertiesOfObject:self includeSuperclasses:YES];
	
	return view;
}

@end
