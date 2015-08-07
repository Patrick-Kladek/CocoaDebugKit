//
//  pkDebugView.m
//  pkDebugFramework
//
//  Created by Patrick Kladek on 21.05.15.
//  Copyright (c) 2015 Patrick Kladek. All rights reserved.
//

#import "pkDebugView.h"
#import <objc/runtime.h>

@interface pkDebugView ()

- (void)internalAddLineWithDescription:(NSString *)desc string:(NSString *)value leftColor:(NSColor *)leftColor rightColor:(NSColor *)rightColor;

@end

@implementation pkDebugView

+ (pkDebugView *)debugView
{
	pkDebugView *view = [[pkDebugView alloc] init];
	return view;
}

+ (NSData *)getSubData:(NSData *)source withRange:(NSRange)range
{
	UInt8 bytes[range.length];
	[source getBytes:&bytes range:range];
	NSData *result = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
	return result;
}

+ (pkDebugView *)debugViewWithAllPropertiesOfObject:(NSObject *)obj
{
	pkDebugView *view = [[pkDebugView alloc] init];
	[view setHighlightKeywords:YES];
	[view setHighlightNumbers:YES];
	[view setTitle:[obj className]];
	
	
	// get all properties and Display them in DebugView ...
	unsigned int outCount, i;
	objc_property_t *properties = class_copyPropertyList([obj class], &outCount);
	for (i = 0; i < outCount; i++) {
		objc_property_t property = properties[i];
		const char *propName = property_getName(property);
		if(propName)
		{
			const char *type = getPropertyType(property);
			
			
			NSString *propertyName = [NSString stringWithUTF8String:propName];
			NSString *propertyType = [NSString stringWithUTF8String:type];
			
//			NSLog(@"type: %@", propertyType);
			
			id object = [[NSClassFromString(propertyType) alloc] init];		// every Obj-C Object ...
			if (object)
			{
				id property = [obj valueForKey:propertyName];
//				if (property == nil) {
//					property = @"nil";
//				}
				
				
				if ([object isKindOfClass:[NSData class]])
				{
					NSData *data = (NSData *)property;
					NSString *string = [NSString stringWithFormat:@"%@ ...", [self getSubData:data withRange:NSMakeRange(0, 40)]];
					[view addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] string:string];
				}
				else if ([object isKindOfClass:[NSImage class]])
				{
					NSString *string = [NSString stringWithFormat:@"%@", [property debugDescription]];
//					NSString *string = @"image ...";
					[view addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] string:string];
				}
				else
				{
					NSString *string = [NSString stringWithFormat:@"%@", property];
					[view addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] string:string];
				}

			}
			
			if ([propertyType isEqualToString:@"id"])										// id
			{
				id property = [obj valueForKey:propertyName];
				
				NSString *string = [NSString stringWithFormat:@"%@", property];
				[view addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] string:string];
			}
			
			/*
			if ([propertyType isEqualToString:NSStringFromClass([NSString class])])			// NSString
			{
				[view addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] string:[NSString stringWithFormat:@"%@", [obj valueForKey:propertyName]]];
			}
			
			if ([propertyType isEqualToString:NSStringFromClass([NSDate class])])			// NSDate
			{
				[view addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] string:[NSString stringWithFormat:@"%@", [obj valueForKey:propertyName]]];
			}
			
			if ([propertyType isEqualToString:NSStringFromClass([NSImage class])])			// NSImage
			{
				[view addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] string:[NSString stringWithFormat:@"%@", [obj valueForKey:propertyName]]];
			}*/
			
			
			
			if ([propertyType isEqualToString:@"c"])										// Char
			{
				NSNumber *number = [obj valueForKey:propertyName];
				if ([number boolValue] == true)
				{
					[view addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] boolean:YES];
				}
				else
				{
					[view addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] boolean:NO];
				}
			}
			
			if ([propertyType isEqualToString:@"i"])										// Int
			{
				NSNumber *number = [obj valueForKey:propertyName];
				[view addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] integer:[number integerValue]];
			}
			
			if ([propertyType isEqualToString:@"s"])										// Short
			{
				NSNumber *number = [obj valueForKey:propertyName];
				[view addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] integer:[number shortValue]];
			}
			
			if ([propertyType isEqualToString:@"l"])										// long
			{
				NSNumber *number = [obj valueForKey:propertyName];
				[view addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] integer:[number longValue]];
			}
			
			if ([propertyType isEqualToString:@"q"])										// long long
			{
				NSNumber *number = [obj valueForKey:propertyName];
				[view addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] longnumber:[number longLongValue]];
			}
			
			
			
			if ([propertyType isEqualToString:@"C"])										// unsigned char
			{
				NSNumber *number = [obj valueForKey:propertyName];
				char mchar = [number charValue];
				NSString *string = [NSString stringWithFormat:@"%c", mchar];
				[view addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] string:string];
			}
			
			if ([propertyType isEqualToString:@"I"])										// unsigned Int
			{
				NSNumber *number = [obj valueForKey:propertyName];
				[view addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] unsignedInteger:[number unsignedIntegerValue]];
			}
			
			if ([propertyType isEqualToString:@"S"])										// unsigned Short
			{
				NSNumber *number = [obj valueForKey:propertyName];
				[view addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] integer:[number unsignedShortValue]];
			}
			
			if ([propertyType isEqualToString:@"L"])										// unsigned long
			{
				NSNumber *number = [obj valueForKey:propertyName];
				[view addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] unsignedInteger:[number unsignedLongValue]];
			}
			
			if ([propertyType isEqualToString:@"Q"])										// unsigned long long
			{
				NSNumber *number = [obj valueForKey:propertyName];
				[view addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] unsignedLongnumber:[number unsignedLongLongValue]];
			}
			
			
			if ([propertyType isEqualToString:@"f"])										// float
			{
				NSNumber *number = [obj valueForKey:propertyName];
				[view addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] floating:[number floatValue]];
			}
			
			if ([propertyType isEqualToString:@"d"])										// double
			{
				NSNumber *number = [obj valueForKey:propertyName];
				[view addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] floating:[number doubleValue]];
			}
			
			
			if ([propertyType isEqualToString:@"*"])										// char * (pointer)
			{
				NSString *string = [NSString stringWithFormat:@"%@", [obj valueForKey:propertyName]];
				
				[view addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] string:[NSString stringWithFormat:@"%@", string]];
			}
			
		}
	}
	free(properties);
	
	
	return view;
}

static const char * getPropertyType(objc_property_t property)
{
	const char *attributes = property_getAttributes(property);
//	printf("attributes=%s\n", attributes);
	char buffer[1 + strlen(attributes)];
	strcpy(buffer, attributes);
	char *state = buffer, *attribute;
	while ((attribute = strsep(&state, ",")) != NULL) {
		if (attribute[0] == 'T' && attribute[1] != '@') {
			// it's a C primitive type:
			/*
			 if you want a list of what will be returned for these primitives, search online for
			 "objective-c" "Property Attribute Description Examples"
			 apple docs list plenty of examples of what you get for int "i", long "l", unsigned "I", struct, etc.
			 */
			return (const char *)[[NSData dataWithBytes:(attribute + 1) length:strlen(attribute) - 1] bytes];
		}
//		else if (attribute[0] == 'T' && attribute[1] == '@')
//		{
//			// it's an ObjC id type:
//			return "id";
//		}
		else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
			// it's an ObjC id type:
			return "id";
		}
		else if (attribute[0] == 'T' && attribute[1] == '@') {
			// it's another ObjC object type:
			return (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
		}
	}
	return "";
}






- (instancetype)init
{
	self = [super init];
	if (self)
	{
		leftWidth				= 0;
		rightWidth				= 0;
		pos						= 30;
		_space					= 7;
		_highlightKeywords		= true;
		_highlightNumbers		= true;
		_title					= @"pkDebugView";
		_color					= [NSColor blueColor];
		_keywordColor			= [NSColor colorWithCalibratedRed:0.592 green:0.000 blue:0.496 alpha:1.000];
		_numberColor			= [NSColor colorWithCalibratedRed:0.077 green:0.000 blue:0.766 alpha:1.000];
		[self setTitle:_title];
	
		self.layer = _layer;
		self.wantsLayer = YES;
		self.layer.masksToBounds = YES;
		
		[self.layer setBackgroundColor:[[NSColor whiteColor] CGColor]];
	}
	return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
	[self setWantsLayer:YES];
	[self.layer setCornerRadius:5];
	[self.layer setBorderColor:[_color CGColor]];
	[self.layer setBorderWidth:1];
	[self setLayer:self.layer];
	
	NSRect rect = NSMakeRect(0, 0, dirtyRect.size.width, 23);
	[_color set];
	NSRectFill(rect);
}

- (BOOL)isFlipped
{
	return YES;
}

#pragma mark - User Interaction

- (void)setTitle:(NSString *)title
{
	_title = title;
	
	if (titleTextField) {
		[titleTextField removeFromSuperview];
	}
	
	titleTextField = [self defaultLabelWithString:title point:NSMakePoint(10, 2) textAlignment:NSLeftTextAlignment];
	[titleTextField setIdentifier:@"title"];
	[titleTextField setAllowsEditingTextAttributes:YES];
	[titleTextField setFont:[NSFont boldSystemFontOfSize:13]];
	[titleTextField setTextColor:[NSColor whiteColor]];
	[titleTextField sizeToFit];
	
	[self addSubview:titleTextField];
	[self setNeedsDisplay:YES];
}

- (void)setColor:(NSColor *)color
{
	_color = color;
	[self setNeedsDisplay:YES];
}

- (void)addLineWithDescription:(NSString *)desc string:(NSString *)value
{
	if (value == nil || value == NULL || [value isEqualToString:@"(null)"])
	{
		value = @"nil";
		
		if (_highlightKeywords == true) {
			[self internalAddLineWithDescription:desc string:value leftColor:[NSColor blackColor] rightColor:_keywordColor];
		} else {
			[self internalAddLineWithDescription:desc string:value leftColor:[NSColor blackColor] rightColor:[NSColor blackColor]];
		}
	}
	else
	{
		[self internalAddLineWithDescription:desc string:value leftColor:[NSColor blackColor] rightColor:[NSColor blackColor]];
	}
}

- (void)addLineWithDescription:(NSString *)desc integer:(NSInteger)integer
{
	NSString *number = [NSString stringWithFormat:@"%li", integer];
	
	if (_highlightNumbers) {
		[self internalAddLineWithDescription:desc string:number leftColor:[NSColor blackColor] rightColor:_numberColor];
	} else {
		[self internalAddLineWithDescription:desc string:number leftColor:[NSColor blackColor] rightColor:[NSColor blackColor]];
	}
	
}

- (void)addLineWithDescription:(NSString *)desc unsignedInteger:(NSUInteger)uinteger
{
	NSString *number = [NSString stringWithFormat:@"%lu", uinteger];
	
	if (_highlightNumbers) {
		[self internalAddLineWithDescription:desc string:number leftColor:[NSColor blackColor] rightColor:_numberColor];
	} else {
		[self internalAddLineWithDescription:desc string:number leftColor:[NSColor blackColor] rightColor:[NSColor blackColor]];
	}
}

- (void)addLineWithDescription:(NSString *)desc longnumber:(long long)number
{
	NSString *num = [NSString stringWithFormat:@"%lli", number];
	
	if (_highlightNumbers) {
		[self internalAddLineWithDescription:desc string:num leftColor:[NSColor blackColor] rightColor:_numberColor];
	} else {
		[self internalAddLineWithDescription:desc string:num leftColor:[NSColor blackColor] rightColor:[NSColor blackColor]];
	}
}

- (void)addLineWithDescription:(NSString *)desc unsignedLongnumber:(unsigned long long)number
{
	NSString *num = [NSString stringWithFormat:@"%llu", number];
	
	if (_highlightNumbers) {
		[self internalAddLineWithDescription:desc string:num leftColor:[NSColor blackColor] rightColor:_numberColor];
	} else {
		[self internalAddLineWithDescription:desc string:num leftColor:[NSColor blackColor] rightColor:[NSColor blackColor]];
	}
}

- (void)addLineWithDescription:(NSString *)desc floating:(double)floating
{
	NSString *number = [NSString stringWithFormat:@"%3.8f", floating];
	
	if (_highlightNumbers) {
		[self internalAddLineWithDescription:desc string:number leftColor:[NSColor blackColor] rightColor:_numberColor];
	} else {
		[self internalAddLineWithDescription:desc string:number leftColor:[NSColor blackColor] rightColor:[NSColor blackColor]];
	}
}

- (void)addLineWithDescription:(NSString *)desc boolean:(BOOL)boolean
{
	NSString *result;
	
	if (boolean) {
		result = @"YES";
	} else {
		result = @"NO";
	}
	
	if (_highlightKeywords) {
		[self internalAddLineWithDescription:desc string:result leftColor:[NSColor blackColor] rightColor:_keywordColor];
	} else {
		[self internalAddLineWithDescription:desc string:result leftColor:[NSColor blackColor] rightColor:[NSColor blackColor]];
	}
}

#pragma mark - Intern

- (void)internalAddLineWithDescription:(NSString *)desc string:(NSString *)value leftColor:(NSColor *)leftColor rightColor:(NSColor *)rightColor
{
	NSTextField *left = [self defaultLabelWithString:desc point:NSMakePoint(10, pos) textAlignment:NSRightTextAlignment];
	
	[left setStringValue:[left.stringValue stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[left.stringValue substringToIndex:1] capitalizedString]]];
	
	
	[left setIdentifier:@"left"];
	[left setTextColor:leftColor];
	[left setFont:[NSFont fontWithName:@"Lucida Grande" size:[NSFont smallSystemFontSize]+0.0]];
	[left sizeToFit];
	
	[left setFrame:NSMakeRect(left.frame.origin.x, left.frame.origin.y + 2.5, left.frame.size.width, left.frame.size.height + 2.5)];
	
	if (left.frame.size.width > leftWidth) {
		leftWidth = left.frame.size.width;
	}
	[self addSubview:left];
	
	
	
	NSTextField *right = [self defaultLabelWithString:value point:NSMakePoint(10 + leftWidth + 20, pos) textAlignment:NSLeftTextAlignment];
	[right setIdentifier:@"right"];
	[right setTextColor:rightColor];
	[right setFont:[NSFont fontWithName:@"Menlo" size:[NSFont smallSystemFontSize]]];
	[right sizeToFit];
	
	if (right.frame.size.width > rightWidth) {
		rightWidth = right.frame.size.width;
	}
	
	pos = pos + right.frame.size.height + _space;
	[self addSubview:right];
	[self resizeLeftTextViews];
	[self resizeRightTextViews];
	[self setFrame:NSMakeRect(0, 0, 10 + leftWidth + 20 + rightWidth + 10, pos)];
}

- (NSTextField *)defaultLabelWithString:(NSString *)string point:(NSPoint)point textAlignment:(NSTextAlignment)align
{
	NSTextField *textField = [[NSTextField alloc] initWithFrame:NSMakeRect(point.x, point.y, 100, 100)];
	[textField setBordered:NO];
	[textField setEditable:NO];
	[textField setAlignment:align];
	[textField setBackgroundColor:[NSColor clearColor]];
	[textField setStringValue:string];
//	[textField setFont:[NSFont fontWithName:@"Menlo" size:12]];
//
//	
//	[textField sizeToFit];
	return textField;
}

- (void)resizeLeftTextViews
{
	for (NSView *view in self.subviews)
	{
		if ([[view identifier] isEqualToString:@"left"])
		{
			[view setFrame:NSMakeRect(10, view.frame.origin.y, leftWidth + 10, view.frame.size.height)];
		}
	}
}

- (void)resizeRightTextViews
{
	for (NSView *view in self.subviews)
	{
		if ([[view identifier] isEqualToString:@"right"])
		{
			[view setFrame:NSMakeRect(10 + leftWidth + 20, view.frame.origin.y, rightWidth, view.frame.size.height)];
		}
	}
}

@end
