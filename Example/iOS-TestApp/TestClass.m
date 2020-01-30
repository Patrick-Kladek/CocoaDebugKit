//
//  TestClass.m
//  CocoaDebugKit
//
//  Created by Patrick Kladek on 22.05.17.
//  Copyright (c) 2017 Patrick Kladek. All rights reserved.
//

#import "TestClass.h"
#import <CocoaDebugKit/CocoaDebugKit.h>

@implementation TestClass

- (instancetype)init
{
	self = [super init];
	if (self) {
		_date = [NSDate date];
		_name = @"Holiday";
		_todoDict = @{@"Task1": @"Buy Plane Tickets",
					  @"Task2": @"Buy Hotel Tickets"};

		_url = [[NSBundle mainBundle] URLForResource:@"image" withExtension:@"jpg"];
		_imageData = [NSData dataWithContentsOfURL:_url];
		_image = [[UIImage alloc] initWithData:_imageData];
		
		_prop = nil;
		_check_bool = true;
		_ccheck = 'r';
		_inum = 234;
		_lnum = 347648392;
	}
	return self;
}

- (NSString *)debugDescription
{
	return [[CocoaDebugDescription debugDescriptionForObject:self] stringRepresentation];
}

- (id)debugQuickLookObject
{
	// NOTE: There is a bug in Xcode which will show a empty view in QuickLook when running on an iOS target. To work around this we simply return an UIImage
	return [[CocoaDebugView debugViewWithAllPropertiesOfObject:self includeSuperclasses:YES] imageRepresentation];
}

@end
