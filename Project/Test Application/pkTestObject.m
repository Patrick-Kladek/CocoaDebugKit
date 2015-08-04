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
	pkDebugView *view = [pkDebugView debugViewWithAllPropertiesOfObject:self];
		
	return view;
}

@end
