//
//  pkDebugDescription.m
//  pkDebugFramework
//
//  Created by Patrick Kladek on 19.04.16.
//  Copyright (c) 2016 Patrick Kladek. All rights reserved.
//

#import "pkDebugDescription.h"
#import "pkPropertyEnumerator.h"
#import "pkDebugSettings.h"


@interface pkDebugDescription ()
{
	pkPropertyEnumerator *propertyEnumerator;
	NSString *myDescription;
}

@end



@implementation pkDebugDescription

+ (pkDebugDescription *)debugDescription
{
	pkDebugDescription *description = [[pkDebugDescription alloc] init];
	return description;
}

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		propertyEnumerator = [[pkPropertyEnumerator alloc] init];
		myDescription = @"";
		
		pkDebugSettings *settings = [pkDebugSettings sharedSettings];
		
		self.dataMaxLenght = settings.maxDataLenght;
	}
	return self;
}


- (void)addAllPropertiesFromObject:(NSObject *)obj
{
	Class currentClass = [obj class];
	
	while (currentClass != nil)
	{
		[propertyEnumerator enumerateProperties:currentClass allowed:nil block:^(NSString *type, NSString *name) {
			[self addProperty:name type:type fromObject:obj];
		}];
		
		currentClass = [currentClass superclass];
	}
}

- (void)addProperty:(NSString *)name type:(NSString *)type fromObject:(NSObject *)obj
{
	id value = [obj valueForKey:name];
	
	if ([type isEqualToString:@"NSData"])
	{
		// cut lenght to 100 byte
		if ([(NSData *)value length] > self.dataMaxLenght.integerValue)
		{
			value = [value subdataWithRange:NSMakeRange(0, self.dataMaxLenght.integerValue)];
		}
	}
	
	myDescription = [myDescription stringByAppendingString:[NSString stringWithFormat:@"(%@) %@ = %@,\n", type, name, value]];
}

- (NSString *)descriptionForObject:(NSObject *)object
{
	[self addAllPropertiesFromObject:object];
	
	
	NSMutableArray *lines = [NSMutableArray array];
	
	[[myDescription componentsSeparatedByString:@"\n"] enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
		
		if (obj.length > 0) {
			[lines addObject:[NSString stringWithFormat:@"\t%@", obj]];
		}
	}];
	
	
	NSString *string = [NSString stringWithFormat:@"%@ <%p> {\n%@\n}", NSStringFromClass([object class]), object, [lines componentsJoinedByString:@"\n"]];
	return string;
	
	
}

@end
