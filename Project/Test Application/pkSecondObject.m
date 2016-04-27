//
//  pkSecondObject.m
//  pkDebugFramework
//
//  Created by Patrick Kladek on 25.04.16.
//  Copyright (c) 2016 Patrick Kladek. All rights reserved.
//

#import "pkSecondObject.h"
#import <pkDebugFramework/pkDebugFramework.h>

@implementation pkSecondObject

- (id)debugQuickLookObject
{
	pkDebugView *view = [pkDebugView debugViewWithAllPropertiesOfObject:self includeSubclasses:YES];
	
	return view;
}

@end
