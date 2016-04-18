//
//  pkDebugView.m
//  pkDebugFramework
//
//  Created by Patrick Kladek on 21.05.15.
//  Copyright (c) 2015 Patrick Kladek. All rights reserved.
//

// TODO: calculate hight of labels and resize ...

#import "pkDebugView.h"
#import <objc/runtime.h>



static NSColor *NSColorFromHexString(NSString *inColorString)
{
	NSColor *result = nil;
	unsigned colorCode = 0;
	unsigned char redByte, greenByte, blueByte, alphaByte;
	
	if (nil != inColorString)
	{
		NSScanner *scanner = [NSScanner scannerWithString:inColorString];
		(void) [scanner scanHexInt:&colorCode]; // ignore error
	}
	redByte = (unsigned char)(colorCode >> 24);
	greenByte = (unsigned char)(colorCode >> 16);
	blueByte = (unsigned char)(colorCode >> 8);
	alphaByte = (unsigned char)(colorCode);		// masks off high bits
	
	result = [NSColor colorWithCalibratedRed:(CGFloat)redByte / 0xff green:(CGFloat)greenByte / 0xff blue:(CGFloat)blueByte / 0xff alpha:(CGFloat)alphaByte / 0xff];
	return result;
}






@interface pkDebugView ()
{
	NSInteger pos;
	NSInteger leftWidth;
	NSInteger rightWidth;
	
	NSTextField *titleTextField;
}

- (void)_addLineWithDescription:(NSString *)desc string:(NSString *)value leftColor:(NSColor *)leftColor rightColor:(NSColor *)rightColor;

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

//	[view setTitle:[obj className]];
	[view setTitle:[NSString stringWithFormat:@"%@ : %@", [obj class], [obj superclass]]];
	[view enumerateProperties:obj allowed:nil];

	return view;
}

+ (pkDebugView *)debugViewWithProperties:(NSString *)properties ofObject:(NSObject *)obj
{
	pkDebugView *view = [[pkDebugView alloc] init];
	[view setTitle:[NSString stringWithFormat:@"%@ : %@", [obj class], [obj superclass]]];
	
	[view addProperties:properties fromObject:obj];
	
	return view;
}

static const char *getPropertyType(objc_property_t property)
{
	const char *attributes = property_getAttributes(property);
	char buffer[1 + strlen(attributes)];
	strcpy(buffer, attributes);
	char *state = buffer, *attribute;
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
		
		_textColor				= [NSColor blackColor];
		_backgroundColor		= [NSColor whiteColor];
		_frameColor				= [NSColor blueColor];
		_keywordColor			= [NSColor colorWithCalibratedRed:0.592 green:0.000 blue:0.496 alpha:1.000];
		_numberColor			= [NSColor colorWithCalibratedRed:0.077 green:0.000 blue:0.766 alpha:1.000];
		[self setTitle:_title];
	
		self.layer = _layer;
		self.wantsLayer = YES;
		self.layer.masksToBounds = YES;
		
		[self.layer setBackgroundColor:[_backgroundColor CGColor]];
		
		
		[self setDefaultsFromUrl:[[NSBundle mainBundle] URLForResource:@"com.kladek.pkDebugFramework.settings" withExtension:@"plist"]];
	}
	return self;
}

- (void)setDefaultsFromUrl:(NSURL *)url
{
	if (![url isFileURL]) {
		return;
	}
	
	
	NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfURL:url];
	
	_highlightNumbers = [[dict valueForKeyPath:@"numbers.highlight"] boolValue];
	_numberColor = NSColorFromHexString([dict valueForKeyPath:@"numbers.color"]);
	_numberFont = [NSFont fontWithName:[dict valueForKeyPath:@"numbers.font"] size:[[dict valueForKeyPath:@"numbers.size"] integerValue]];
	
	
	_highlightKeywords = [[dict valueForKeyPath:@"keywords.highlight"] boolValue];
	_keywordColor = NSColorFromHexString([dict valueForKeyPath:@"keywords.color"]);
	_keywordFont = [NSFont fontWithName:[dict valueForKeyPath:@"keywords.font"] size:[[dict valueForKeyPath:@"keywords.size"] integerValue]];
	
	_textColor = NSColorFromHexString([dict valueForKeyPath:@"text.color"]);
	_textFont = [NSFont fontWithName:[dict valueForKeyPath:@"text.font"] size:[[dict valueForKeyPath:@"text.size"] integerValue]];
	
	_propertyNameColor = NSColorFromHexString([dict valueForKeyPath:@"propertyName.color"]);
	_propertyNameFont = [NSFont fontWithName:[dict valueForKeyPath:@"propertyName.font"] size:[[dict valueForKeyPath:@"propertyName.size"] integerValue]];
	
	
	
	_imageSize = NSSizeFromString([dict valueForKeyPath:@"image.size"]);
	
	
	_backgroundColor = NSColorFromHexString([dict valueForKeyPath:@"appearance.backgroundColor"]);
	_frameColor = NSColorFromHexString([dict valueForKeyPath:@"appearance.frameColor"]);
}


- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
	// TODO: change this
	if (titleTextField.frame.size.width + 20 > self.frame.size.width)	// +20 => | 10 --- label ----- 10 |
	{
		[self setFrame:NSMakeRect(self.frame.origin.x, self.frame.origin.y, titleTextField.frame.size.width + 20, self.frame.size.height)];
	}
	
	[self setWantsLayer:YES];
	[self.layer setCornerRadius:5];
	[self.layer setBorderColor:[_frameColor CGColor]];
	[self.layer setBorderWidth:1];
	[self setLayer:self.layer];
	
	[self.layer setBackgroundColor:[_backgroundColor CGColor]];
	
	NSRect rect = NSMakeRect(0, 0, dirtyRect.size.width, 23);
	[_frameColor set];
	NSRectFill(rect);
}

- (BOOL)isFlipped
{
	return YES;
}



#pragma mark - Apperance

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
	_frameColor = color;
	[self setNeedsDisplay:YES];
}



#pragma mark - Add Data

- (void)addAllPropertiesFromObject:(NSObject *)obj
{
	[self enumerateProperties:obj allowed:nil];
}

- (void)addProperties:(NSString *)string fromObject:(NSObject *)obj
{
	if (string && string.length > 0)
	{
		NSArray *properties = [string componentsSeparatedByString:@", "];
		
		if (!properties)
		{
			@throw @"malformed properties parameter!";
		}
		
		[properties enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {
			
			[self addProperty:key type:[self propertyTypeFromName:key object:obj] toObject:obj];
		}];
	}
}



- (void)addLineWithDescription:(NSString *)desc string:(NSString *)value
{
	if (value == nil || value == NULL || [value isEqualToString:@"(null)"])
	{
		value = @"nil";
		
		if (_highlightKeywords == true) {
			[self _addLineWithDescription:desc string:value leftColor:_propertyNameColor rightColor:_keywordColor leftFont:_propertyNameFont rightFont:_keywordFont];
		} else {
			[self _addLineWithDescription:desc string:value leftColor:_propertyNameColor rightColor:_textColor leftFont:_propertyNameFont rightFont:_keywordFont];
		}
	}
	else
	{
		[self _addLineWithDescription:desc string:value leftColor:_propertyNameColor rightColor:_textColor leftFont:_propertyNameFont rightFont:_textFont];
	}
}

- (void)addLineWithDescription:(NSString *)desc integer:(NSInteger)integer
{
	NSString *number = [NSString stringWithFormat:@"%li", integer];
	
	if (_highlightNumbers) {
		[self _addLineWithDescription:desc string:number leftColor:_propertyNameColor rightColor:_numberColor leftFont:_propertyNameFont rightFont:_numberFont];
	} else {
		[self _addLineWithDescription:desc string:number leftColor:_propertyNameColor rightColor:_textColor leftFont:_propertyNameFont rightFont:_textFont];
	}
}

- (void)addLineWithDescription:(NSString *)desc unsignedInteger:(NSUInteger)uinteger
{
	NSString *number = [NSString stringWithFormat:@"%lu", uinteger];
	
	if (_highlightNumbers) {
		[self _addLineWithDescription:desc string:number leftColor:_propertyNameColor rightColor:_numberColor leftFont:_propertyNameFont rightFont:_numberFont];
	} else {
		[self _addLineWithDescription:desc string:number leftColor:_propertyNameColor rightColor:_textColor leftFont:_propertyNameFont rightFont:_keywordFont];
	}
}

- (void)addLineWithDescription:(NSString *)desc longnumber:(long long)number
{
	NSString *num = [NSString stringWithFormat:@"%lli", number];
	
	if (_highlightNumbers) {
		[self _addLineWithDescription:desc string:num leftColor:_propertyNameColor rightColor:_numberColor leftFont:_propertyNameFont rightFont:_numberFont];
	} else {
		[self _addLineWithDescription:desc string:num leftColor:_propertyNameColor rightColor:_textColor leftFont:_propertyNameFont rightFont:_keywordFont];
	}
}

- (void)addLineWithDescription:(NSString *)desc unsignedLongnumber:(unsigned long long)number
{
	NSString *num = [NSString stringWithFormat:@"%llu", number];
	
	if (_highlightNumbers) {
		[self _addLineWithDescription:desc string:num leftColor:_propertyNameColor rightColor:_numberColor leftFont:_propertyNameFont rightFont:_numberFont];
	} else {
		[self _addLineWithDescription:desc string:num leftColor:_propertyNameColor rightColor:_textColor leftFont:_propertyNameFont rightFont:_keywordFont];
	}
}

- (void)addLineWithDescription:(NSString *)desc floating:(double)floating
{
	NSString *number = [NSString stringWithFormat:@"%3.8f", floating];
	
	if (_highlightNumbers) {
		[self _addLineWithDescription:desc string:number leftColor:_propertyNameColor rightColor:_numberColor leftFont:_propertyNameFont rightFont:_numberFont];
	} else {
		[self _addLineWithDescription:desc string:number leftColor:_propertyNameColor rightColor:_textColor leftFont:_propertyNameFont rightFont:_keywordFont];
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
		[self _addLineWithDescription:desc string:result leftColor:_propertyNameColor rightColor:_keywordColor leftFont:_propertyNameFont rightFont:_keywordFont];
	} else {
		[self _addLineWithDescription:desc string:result leftColor:_propertyNameColor rightColor:_textColor leftFont:_propertyNameFont rightFont:_keywordFont];
	}
}

- (void)addLineWithDescription:(NSString *)desc image:(NSImage *)image
{
	NSTextField *left = [self defaultLabelWithString:desc point:NSMakePoint(10, pos) textAlignment:NSRightTextAlignment];
	
//	[left setStringValue:[left.stringValue stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[left.stringValue substringToIndex:1] capitalizedString]]];
	[left setStringValue:[left.stringValue capitalizedString]];
	
	
	[left setIdentifier:@"left"];
	[left setTextColor:_propertyNameColor];
	[left setFont:_propertyNameFont];
	[left sizeToFit];
	
	[left setFrame:NSMakeRect(left.frame.origin.x, left.frame.origin.y + 2.5, left.frame.size.width, left.frame.size.height + 2.5)];
	
	if (left.frame.size.width > leftWidth) {
		leftWidth = left.frame.size.width;
	}
	[self addSubview:left];
	
	
	
	NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(10 + leftWidth + 20, pos, _imageSize.width, _imageSize.height)];
	[imageView setImage:image];
	[imageView setIdentifier:@"rightImage"];
	[imageView setImageScaling:NSImageScaleProportionallyUpOrDown];
	
	if (imageView.frame.size.width > rightWidth) {
		rightWidth = imageView.frame.size.width;
	}
	
	pos = pos + imageView.frame.size.height + _space;
	[self addSubview:imageView];
	[self resizeLeftTextViews];
	[self resizeRightTextViews];
	[self setFrame:NSMakeRect(0, 0, 10 + leftWidth + 20 + rightWidth + 10, pos)];
}



#pragma mark - Intern

- (void)addProperty:(NSString *)propertyName type:(NSString *)propertyType toObject:(NSObject *)obj
{
	id object = [[NSClassFromString(propertyType) alloc] init];		// every Obj-C Object ...
	if (object)
	{
		id property = [obj valueForKey:propertyName];

		
		
		if ([object isKindOfClass:[NSData class]])
		{
			NSData *data = (NSData *)property;
			NSString *string = [NSString stringWithFormat:@"%@ ...", [pkDebugView getSubData:data withRange:NSMakeRange(0, 20)]];
			[self addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] string:string];
		}
		else if ([object isKindOfClass:[NSImage class]])
		{
			if (property)
			{
				[self addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] image:property];
			}
		}
		else
		{
			NSString *string = [NSString stringWithFormat:@"%@", property];
			[self addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] string:string];
		}
		
	}
	else if ([propertyType isEqualToString:@"id"])										// id
	{
		id property = [obj valueForKey:propertyName];
		
		NSString *string = [NSString stringWithFormat:@"%@", property];
		[self addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] string:string];
	}
	else if ([propertyType isEqualToString:@"NSURL"])									// NSURL
	{
		id property = [obj valueForKey:propertyName];
		
		NSString *string = [NSString stringWithFormat:@"%@", property];
		[self addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] string:string];
	}
	else if ([propertyType isEqualToString:@"c"])										// Char
	{
		NSNumber *number = [obj valueForKey:propertyName];
		if ([number boolValue] == true)
		{
			[self addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] boolean:YES];
		}
		else
		{
			[self addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] boolean:NO];
		}
	}
	else if ([propertyType isEqualToString:@"i"])										// Int
	{
		NSNumber *number = [obj valueForKey:propertyName];
		[self addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] integer:[number integerValue]];
	}
	else if ([propertyType isEqualToString:@"s"])										// Short
	{
		NSNumber *number = [obj valueForKey:propertyName];
		[self addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] integer:[number shortValue]];
	}
	else if ([propertyType isEqualToString:@"l"])										// long
	{
		NSNumber *number = [obj valueForKey:propertyName];
		[self addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] integer:[number longValue]];
	}
	else if ([propertyType isEqualToString:@"q"])										// long long
	{
		NSNumber *number = [obj valueForKey:propertyName];
		[self addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] longnumber:[number longLongValue]];
	}
	else if ([propertyType isEqualToString:@"C"])										// unsigned char
	{
		NSNumber *number = [obj valueForKey:propertyName];
		char mchar = [number charValue];
		NSString *string = [NSString stringWithFormat:@"%c", mchar];
		[self addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] string:string];
	}
	else if ([propertyType isEqualToString:@"I"])										// unsigned Int
	{
		NSNumber *number = [obj valueForKey:propertyName];
		[self addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] unsignedInteger:[number unsignedIntegerValue]];
	}
	else if ([propertyType isEqualToString:@"S"])										// unsigned Short
	{
		NSNumber *number = [obj valueForKey:propertyName];
		[self addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] integer:[number unsignedShortValue]];
	}
	else if ([propertyType isEqualToString:@"L"])										// unsigned long
	{
		NSNumber *number = [obj valueForKey:propertyName];
		[self addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] unsignedInteger:[number unsignedLongValue]];
	}
	else if ([propertyType isEqualToString:@"Q"])										// unsigned long long
	{
		NSNumber *number = [obj valueForKey:propertyName];
		[self addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] unsignedLongnumber:[number unsignedLongLongValue]];
	}
	else if ([propertyType isEqualToString:@"f"])										// float
	{
		NSNumber *number = [obj valueForKey:propertyName];
		[self addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] floating:[number floatValue]];
	}
	else if ([propertyType isEqualToString:@"d"])										// double
	{
		NSNumber *number = [obj valueForKey:propertyName];
		[self addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] floating:[number doubleValue]];
	}
	else if ([propertyType isEqualToString:@"*"])										// char * (pointer)
	{
		NSString *string = [NSString stringWithFormat:@"%@", [obj valueForKey:propertyName]];
		
		[self addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] string:[NSString stringWithFormat:@"%@", string]];
	}
	else
	{
		// if first char == '<' and last char == '>' then some delegate ...
		NSString *firstChar = [propertyType substringToIndex:1];
		NSString *lastChar = [propertyType substringFromIndex:propertyType.length-1];
		
		if ([firstChar isEqualToString:@"<"] && [lastChar isEqualToString:@">"])
		{
			// Delegate ...
			[self addLineWithDescription:propertyName string:propertyType];
		}
	}
}

- (void)enumerateProperties:(NSObject *)obj allowed:(NSString *)allowed
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
			
			if (allowed && ![allowed isEqualToString:propertyName])
			{
				continue;
			}
			
			[self addProperty:propertyName type:propertyType toObject:obj];
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




- (void)_addLineWithDescription:(NSString *)desc string:(NSString *)value leftColor:(NSColor *)leftColor rightColor:(NSColor *)rightColor leftFont:(NSFont *)lFont rightFont:(NSFont *)rfont
{
	NSTextField *left = [self defaultLabelWithString:desc point:NSMakePoint(10, pos) textAlignment:NSRightTextAlignment];
	
	[left setStringValue:[left.stringValue stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[left.stringValue substringToIndex:1] capitalizedString]]];
	
	
	[left setIdentifier:@"left"];
	[left setTextColor:leftColor];
	[left setFont:lFont];
	[left sizeToFit];
	
	[left setFrame:NSMakeRect(left.frame.origin.x, left.frame.origin.y + 0.5, left.frame.size.width, left.frame.size.height + 0.5)];
	
	if (left.frame.size.width > leftWidth) {
		leftWidth = left.frame.size.width;
	}
	[self addSubview:left];
	
	
	
	NSTextField *right = [self defaultLabelWithString:value point:NSMakePoint(10 + leftWidth + 20, pos) textAlignment:NSLeftTextAlignment];
	[right setIdentifier:@"right"];
	[right setTextColor:rightColor];
	[right setFont:rfont];
	[right sizeToFit];
	
	if (right.frame.size.width > rightWidth) {
		rightWidth = right.frame.size.width;
	}
	
	
	
	pos = pos + fmaxf(left.frame.size.height, right.frame.size.height) + _space;
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
		
		if ([[view identifier] isEqualToString:@"rightImage"])
		{
			[view setFrame:NSMakeRect(10 + leftWidth + 20, view.frame.origin.y, view.frame.size.width, view.frame.size.height)];
		}
	}
}

@end
