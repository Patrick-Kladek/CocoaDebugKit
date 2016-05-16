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
		
		self.dataMaxLenght	= settings.maxDataLenght;
		self.save			= settings.save;
		self.saveUrl		= settings.saveUrl;
	}
	return self;
}


- (void)addAllPropertiesFromObject:(NSObject *)obj
{
	_obj = obj;
	
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
	
	if (_save) {
		[self saveDebugDescription];
	}
	
	NSString *string = [NSString stringWithFormat:@"%@ <%p> {\n%@\n}", NSStringFromClass([object class]), object, [lines componentsJoinedByString:@"\n"]];
	return string;
}

- (void)saveDebugDescription
{
	NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
	NSString *appVersion = [infoDict objectForKey:@"CFBundleShortVersionString"]; 	// example: 1.0.0
	NSString *buildNumber = [infoDict objectForKey:@"CFBundleVersion"]; 			// example: 42
	
	NSURL *url = [_saveUrl URLByAppendingPathComponent:appVersion];
	url = [url URLByAppendingPathComponent:buildNumber];
	
	NSError *error;
	if (![[NSFileManager defaultManager] createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&error])
	{
		NSAlert *alert = [NSAlert alertWithError:error];
		[alert runModal];
		return;
	}
	
	NSDictionary *debuggedObjects = [[pkDebugSettings sharedSettings] debuggedObjects];
	NSInteger debuggedNr = [[debuggedObjects valueForKey:[_obj className]] integerValue];
	debuggedNr++;
	[debuggedObjects setValue:[NSNumber numberWithInteger:debuggedNr] forKey:[_obj className]];
	url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@ %li.txt", [_obj className], debuggedNr]];
	
	[self saveDebugDescriptionToUrl:url];
}

- (BOOL)saveDebugDescriptionToUrl:(NSURL *)url
{
	NSError *error;
	
	return [myDescription writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:&error];
}

@end
