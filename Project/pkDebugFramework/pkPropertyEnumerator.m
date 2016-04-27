//
//  pkPropertyEnumerator.m
//  pkDebugFramework
//
//  Created by Patrick Kladek on 25.04.16.
//  Copyright (c) 2016 Patrick Kladek. All rights reserved.
//

#import "pkPropertyEnumerator.h"
#import <objc/runtime.h>

@implementation pkPropertyEnumerator

static const char *getPropertyType(objc_property_t property)
{
	const char *attributes = property_getAttributes(property);
	char buffer[1 + strlen(attributes)];
	strcpy(buffer, attributes);
	char *state = buffer, *attribute;
	
	printf("%s\n", attributes);
//	T@"NSString",&,N,V_hallo
//	T@"<pkTestObjectDelegate>",W,N,V_delegate
//	T@"NSData",&,N,V_data
//	T@"NSDate",&,N,V_date
//	T@"NSImage",&,N,V_image
//	T@,&,N,V_prop
//	T@"NSSet",&,N,V_set
//	T@"NSString",&,N,V_name
//	T@"NSString",&,N,V_test
//	Tc,N,GisCheck,V_check
//	TC,N,V_ccheck
//	Ti,N,V_inum
//	Tq,N,V_lnum
//	T@"NSURL",&,N,V_url
//	T@"pkTestObject",&,N,V_object
//	T@"NSString",&,N,V_hallo
//	T@"<pkTestObjectDelegate>",W,N,V_delegate
//	T@"NSData",&,N,V_data
//	T@"NSDate",&,N,V_date
//	T@"NSImage",&,N,V_image
//	T@,&,N,V_prop
//	T@"NSSet",&,N,V_set
//	T@"NSString",&,N,V_name
//	T@"NSString",&,N,V_test
//	Tc,N,GisCheck,V_check
//	TC,N,V_ccheck
//	Ti,N,V_inum
//	Tq,N,V_lnum
//	T@"NSURL",&,N,V_url
//	T@"pkTestObject",&,N,V_object
	
	while ((attribute = strsep(&state, ",")) != NULL)
	{
		if (attribute[0] == 'T' && attribute[1] != '@')
		{
			// it's a C primitive type:
			/*
			 if you want a list of what will be returned for these primitives, search online for
			 "objective-c" "Property Attribute Description Examples"
			 apple docs list plenty of examples of what you get for int "i", long "l", unsigned "I", struct, etc.
			 */
			return (const char *)[[NSData dataWithBytes:(attribute + 1) length:strlen(attribute) - 1] bytes];
		}
		else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2)
		{
			// it's an ObjC id type:
			return "id";
		}
		else if (attribute[0] == 'T' && attribute[1] == '@')
		{
			// it's another ObjC object type:
			return (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
		}
	}
	return "";
}

- (void)enumerateProperties:(Class)objectClass allowed:(NSString *)allowed block:(void (^)(NSString *type, NSString *name))callbackBlock
{
	// get all properties and Display them in DebugView ...
	unsigned int outCount, i;
	objc_property_t *properties = class_copyPropertyList(objectClass, &outCount);
	
	for (i = 0; i < outCount; i++)
	{
		objc_property_t property = properties[i];
		const char *propName = property_getName(property);
		
		if (propName)
		{
			const char *type = getPropertyType(property);
			NSString *propertyName = [NSString stringWithUTF8String:propName];
			NSString *propertyType = [NSString stringWithUTF8String:type];
			
			if (allowed && ![allowed isEqualToString:propertyName])
			{
				continue;
			}
			
			callbackBlock(propertyType, propertyName);
		}
	}
	free(properties);
}

- (NSString *)propertyTypeFromName:(NSString *)name object:(NSObject *)obj
{
	// get all properties and Display them in DebugView ...
	unsigned int outCount, i;
	objc_property_t *properties = class_copyPropertyList([obj class], &outCount);
	
	for (i = 0; i < outCount; i++)
	{
		objc_property_t property = properties[i];
		const char *propName = property_getName(property);
		
		if (propName)
		{
			const char *type = getPropertyType(property);
			NSString *propertyName = [NSString stringWithUTF8String:propName];
			NSString *propertyType = [NSString stringWithUTF8String:type];
			
			if ([propertyName isEqualToString:name])
			{
				return propertyType;
			}
		}
	}
	free(properties);
	
	return nil;
}

@end
