//
//  CocoaDebugView.m
//  CocoaDebugKit
//
//  Created by Patrick Kladek on 21.05.15.
//  Copyright (c) 2015 Patrick Kladek. All rights reserved.
//

#import "CocoaDebugView.h"
#import <objc/runtime.h>
#import "CocoaDebugSettings.h"
#import "CocoaPropertyEnumerator.h"
#import <Foundation/Foundation.h>



@interface CocoaDebugView ()
{
	NSInteger pos;
	NSInteger leftWidth;
	NSInteger rightWidth;
	
	NSTextField *titleTextField;
	NSTextField *defaultTextField;
	
	CocoaPropertyEnumerator *propertyEnumerator;
}

- (void)_addLineWithDescription:(NSString *)desc string:(NSString *)value leftColor:(NSColor *)leftColor rightColor:(NSColor *)rightColor leftFont:(NSFont *)lFont rightFont:(NSFont *)rfont;

@end



@implementation CocoaDebugView


+ (CocoaDebugView *)debugView
{
	CocoaDebugView *view = [[CocoaDebugView alloc] init];
	return view;
}

+ (NSData *)getSubData:(NSData *)source withRange:(NSRange)range
{
	UInt8 bytes[range.length];
	[source getBytes:&bytes range:range];
	NSData *result = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes)];
	return result;
}

+ (CocoaDebugView *)debugViewWithAllPropertiesOfObject:(NSObject *)obj includeSuperclasses:(BOOL)include
{
	CocoaDebugView *view = [[CocoaDebugView alloc] init];
	[view setObj:obj];
	
	if (include) {
		[view setTitle:[view traceSuperClassesOfObject:obj]];
	} else {
		[view setTitle:[obj className]];
	}
	
	[view addAllPropertiesFromObject:obj includeSuperclasses:include];
	
	if ([view save]) {
		[view saveDebugView];
	}

	return view;
}

+ (CocoaDebugView *)debugViewWithProperties:(NSArray *)properties ofObject:(NSObject *)obj
{
	CocoaDebugView *view = [[CocoaDebugView alloc] init];
	[view setObj:obj];
	
	[view setTitle:[view traceSuperClassesOfObject:obj]];
	[view addProperties:properties fromObject:obj];
	
	if ([view save]) {
		[view saveDebugView];
	}
	
	return view;
}

+ (CocoaDebugView *)debugViewWithExcludingProperties:(NSArray *)properties ofObject:(NSObject *)obj
{
	CocoaDebugView *view = [CocoaDebugView debugView];
	[view setObj:obj];
	[view setTitle:[view traceSuperClassesOfObject:obj]];
	
	CocoaPropertyEnumerator *enumerator = [[CocoaPropertyEnumerator alloc] init];
	Class currentClass = [obj class];
	
	while (currentClass && currentClass != [NSObject class]) {
		
		[enumerator enumeratePropertiesFromClass:currentClass allowed:nil block:^(NSString *type, NSString *name) {
			BOOL found = false;
			for (NSString *property in properties)
			{
				if ([property isEqualToString:name]) {
					found = true;
					break;
				}
			}
			
			if (!found) {
				[view addProperty:name type:type toObject:obj];
			}
		}];
		
		currentClass = [currentClass superclass];
	}
	
	return view;
}






- (instancetype)init
{
	self = [super init];
	if (self)
	{
		CocoaDebugSettings *settings = [CocoaDebugSettings sharedSettings];
		
		self.lineSpace				= settings.lineSpace;
		self.highlightKeywords		= settings.highlightKeywords;
		self.highlightNumbers		= settings.highlightNumbers;
		
		self.textColor				= settings.textColor;
		self.textFont				= settings.textFont;
		
		self.keywordColor			= settings.keywordColor;
		self.keywordFont			= settings.keywordFont;
		
		self.numberColor			= settings.numberColor;
		self.numberFont				= settings.numberFont;
		
		self.propertyNameColor		= settings.propertyNameColor;
		self.propertyNameFont		= settings.propertyNameFont;
		
		self.titleColor				= settings.titleColor;
		self.titleFont				= settings.titleFont;
		
		self.backgroundColor		= settings.backgroundColor;
		self.frameColor				= settings.frameColor;
		
		self.imageSize				= settings.imageSize;
		self.convertDataToImage		= settings.convertDataToImage;
		self.propertyNameContains	= [NSMutableArray arrayWithArray:[settings propertyNameContains]];
		
		self.save 					= settings.save;
		self.saveUrl				= settings.saveUrl;
		self.saveAsPDF				= settings.saveAsPDF;
		
		self.dateFormat				= settings.dateFormat;
		self.numberOfBitsPerColorComponent = settings.numberOfBitsPerColorComponent;
		
		
		
		propertyEnumerator = [[CocoaPropertyEnumerator alloc] init];
		
		
		leftWidth				= 0;
		rightWidth				= 0;
		pos						= 30;
		_title					= @"CocoaDebugView";
		
		
		[self setFrame:NSMakeRect(0, 0, 20, 55)];
		[self setTitle:_title];
		
		[self setDefaultApperance];
		
		
		self.layer = _layer;
		self.wantsLayer = YES;
		self.layer.masksToBounds = YES;
		
		[self.layer setBackgroundColor:[_backgroundColor CGColor]];
	}
	return self;
}

- (void)setDefaultsFromUrl:(NSURL *)url
{
	if (![url isFileURL]) {
		return;
	}
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
	// Uncomment this to resize view based on title lenght
//	if (titleTextField.frame.size.width + 20 > self.frame.size.width)	// +20 => | 10 --- label ----- 10 |
//	{
//		[self setFrame:NSMakeRect(self.frame.origin.x, self.frame.origin.y, titleTextField.frame.size.width + 20, self.frame.size.height)];
//	}
	
	[self setWantsLayer:YES];
	[self.layer setCornerRadius:5];
	[self.layer setBorderColor:[_frameColor CGColor]];
	[self.layer setBorderWidth:1];
	[self setLayer:self.layer];
	[self.layer setBackgroundColor:[_backgroundColor CGColor]];
	
	NSRect rect = NSMakeRect(0, 0, dirtyRect.size.width, 23);
	
	NSColor *startingColor = [NSColor colorWithRed:_frameColor.redComponent green:_frameColor.greenComponent blue:_frameColor.blueComponent alpha:0.75];
	NSGradient *aGradient = [[NSGradient alloc] initWithStartingColor:startingColor endingColor:_frameColor];
	[aGradient drawInRect:rect angle:90];
}

- (BOOL)isFlipped
{
	return YES;
}



#pragma mark - Apperance

- (void)setDefaultApperance
{
	[self removeDefaultApperance];
	
	defaultTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(10, pos, self.frame.size.width - 20, 20)];
	[defaultTextField setStringValue:@"No Variables"];
	[defaultTextField setTextColor:[NSColor grayColor]];
	[defaultTextField setAlignment:NSCenterTextAlignment];
	[defaultTextField setBordered:NO];
	[defaultTextField setEditable:NO];
	[defaultTextField setBackgroundColor:[NSColor clearColor]];
	[self addSubview:defaultTextField];
}

- (void)removeDefaultApperance
{
	if (defaultTextField) {
		[defaultTextField removeFromSuperview];
		defaultTextField = nil;
	}
}

- (void)setTitle:(NSString *)title
{
	_title = title;
	
	if (titleTextField) {
		[titleTextField removeFromSuperview];
	}
	
	titleTextField = [self defaultLabelWithString:title point:NSMakePoint(10, 2) textAlignment:NSLeftTextAlignment];
	[titleTextField setIdentifier:@"title"];
	[titleTextField setAllowsEditingTextAttributes:YES];
	[titleTextField setFont:_titleFont];
	[titleTextField setTextColor:_titleColor];
	[titleTextField sizeToFit];
	
	if (titleTextField.frame.size.width + 10 > self.frame.size.width) {
		[self setFrame:NSMakeRect(self.frame.origin.x, self.frame.origin.y, titleTextField.frame.size.width + 10, self.frame.size.height)];
	}
	
	[self addSubview:titleTextField];
	
	if (pos == 30) {
		[self setDefaultApperance];
	} else {
		[self removeDefaultApperance];
	}
	
	[self setNeedsDisplay:YES];
}

- (void)setColor:(NSColor *)color
{
	_frameColor = color;
	[self setNeedsDisplay:YES];
}



- (NSString *)traceSuperClassesOfObject:(NSObject *)obj
{
	Class currentClass = [obj class];
	NSString *classStructure = NSStringFromClass(currentClass);
	
	
	while (NSStringFromClass([currentClass superclass]) != nil)
	{
		currentClass = [currentClass superclass];
		classStructure = [classStructure stringByAppendingString:[NSString stringWithFormat:@" : %@", NSStringFromClass(currentClass)]];
	}
	
	return classStructure;
}

#pragma mark - Save

- (void)saveDebugView
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
	
	NSDictionary *debuggedObjects = [[CocoaDebugSettings sharedSettings] debuggedObjects];
	NSInteger debuggedNr = [[debuggedObjects valueForKey:[_obj className]] integerValue];
	debuggedNr++;
	[debuggedObjects setValue:[NSNumber numberWithInteger:debuggedNr] forKey:[_obj className]];
	url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@ %li", [_obj className], debuggedNr]];
	
	if (_saveAsPDF) {
		url = [url URLByAppendingPathExtension:@"pdf"];
	} else {
		url = [url URLByAppendingPathExtension:@"png"];
	}
	
	
	[self saveDebugViewToUrl:url];
}

- (BOOL)saveDebugViewToUrl:(NSURL *)url
{
	if ([[url pathExtension] isEqualToString:@"pdf"])
	{
		NSData *data = [self dataWithPDFInsideRect:[self bounds]];
		return [data writeToURL:url atomically:YES];
	}
	
	
	NSBitmapImageRep *rep = [self bitmapImageRepForCachingDisplayInRect:self.bounds];
	[self cacheDisplayInRect:self.bounds toBitmapImageRep:rep];
	
	NSData *data = [rep representationUsingType:NSPNGFileType properties:nil];
	return [data writeToURL:url atomically:YES];
}



#pragma mark - Add Data

- (void)addAllPropertiesFromObject:(NSObject *)obj includeSuperclasses:(BOOL)include
{
	if (include)
	{
		// enumerate all superclasses "class_copyPropertyList(...)"
		Class currentClass = [obj class];
		
		while (currentClass != nil && currentClass != [NSObject class])
		{
			[propertyEnumerator enumeratePropertiesFromClass:currentClass allowed:nil block:^(NSString *type, NSString *name) {
				[self addProperty:name type:type toObject:obj];
			}];
			
			[self addSeperator];
			
			currentClass = [currentClass superclass];
		}
	}
	else
	{
		[propertyEnumerator enumeratePropertiesFromClass:[obj class] allowed:nil block:^(NSString *type, NSString *name) {
			[self addProperty:name type:type toObject:obj];
		}];
	}
}

- (void)addProperties:(NSArray *)array fromObject:(NSObject *)obj
{
	if (!array || array.count == 0) {
		return;
	}
	
	Class currentClass = [obj class];
	
	while (currentClass && currentClass != [NSObject class])
	{
		[propertyEnumerator enumeratePropertiesFromClass:currentClass allowed:array block:^(NSString *type, NSString *name) {
			[self addProperty:name type:type toObject:obj];
		}];
		
		currentClass = [currentClass superclass];
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

- (void)addLineWithDescription:(NSString *)desc image:(NSImage *)image;
{
	[self removeDefaultApperance];
	
	
	NSTextField *left = [self defaultLabelWithString:desc point:NSMakePoint(10, pos) textAlignment:NSRightTextAlignment];

	if (desc) {
		[left setStringValue:[left.stringValue stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[left.stringValue substringToIndex:1] capitalizedString]]];
	}
	
	
	
	[left setIdentifier:@"left"];
	[left setTextColor:_propertyNameColor];
	[left setFont:_propertyNameFont];
	[left sizeToFit];
	
	[left setFrame:NSMakeRect(left.frame.origin.x, left.frame.origin.y, left.frame.size.width, left.frame.size.height)];
	
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


	[self synchroniseHeightOfView:left secondView:imageView];
	pos = pos + imageView.frame.size.height + _lineSpace;
	[self addSubview:imageView];
	[self resizeLeftTextViews];
	[self resizeRightTextViews];
	[self setFrame:NSMakeRect(0, 0, 10 + leftWidth + 20 + rightWidth + 10, pos)];
}

- (void)addLineWithDescription:(NSString *)desc date:(NSDate *)date
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:_dateFormat];
	NSString *dateString = [dateFormatter stringFromDate:date];
	[self addLineWithDescription:desc string:dateString];
}

- (void)addLineWithDescription:(NSString *)desc view:(NSView *)view
{
	// add left label
	NSTextField *left = [self _addLeftLabel:desc color:_propertyNameColor font:_propertyNameFont];
	
	// add right view
	[view setFrameOrigin:NSMakePoint(10 + leftWidth + 20, pos)];
	[view setIdentifier:@"rightImage"];
	
	
	if (view.frame.size.width > rightWidth) {
		rightWidth = view.frame.size.width;
	}
	
	pos = pos + fmaxf(left.frame.size.height, view.frame.size.height) + _lineSpace;
	[self addSubview:view];
	[self resizeLeftTextViews];
	[self resizeRightTextViews];
	[self setFrame:NSMakeRect(0, 0, 10 + leftWidth + 20 + rightWidth + 10, pos)];
}

- (void)addSeperator
{
	// draw dashed line here
}

#pragma mark - Intern

- (void)addProperty:(NSString *)propertyName type:(NSString *)propertyType toObject:(id)obj
{
	if ([propertyType isEqualToString:@"id"])
	{
		NSString *string = [NSString stringWithFormat:@"%@", [obj valueForKey:propertyName]];
		[self addLineWithDescription:[self lineFromString:propertyName] string:string];
		return;
	}
	
	if ([self addPrimitiveProperty:propertyName type:propertyType toObject:obj])
	{
		return;
	}
	
	
	Class class = NSClassFromString(propertyType);
	
	// First check for Core Data Classes and ignore them
	if ([class isSubclassOfClass:[NSManagedObject class]])
	{
		NSLog(@"Core Data Relationships currently not supported");
		return;
	}
	
	if ([class isSubclassOfClass:[NSString class]])
	{
		NSString *property = [obj valueForKey:propertyName];
		[self addLineWithDescription:[self lineFromString:propertyName] string:property];
		return;
	}
	
	if ([class isSubclassOfClass:[NSData class]])
	{
		id property = [obj valueForKey:propertyName];
		[self addDataProperty:property name:propertyName toObject:obj];
		return;
	}
	
	if ([class isSubclassOfClass:[NSDate class]])
	{
		id property = [obj valueForKey:propertyName];
		[self addLineWithDescription:[self lineFromString:propertyName] date:property];
		return;
	}
	
	if ([class isSubclassOfClass:[NSImage class]])
	{
		id property = [obj valueForKey:propertyName];
		[self addLineWithDescription:[self lineFromString:propertyName] image:property];
		return;
	}
	
	if ([class isSubclassOfClass:[NSURL class]])
	{
		NSURL *url = [obj valueForKey:propertyName];
		[self addLineWithDescription:[self lineFromString:propertyName] string:[url absoluteString]];
		return;

	}
	
	if ([class isSubclassOfClass:[NSSet class]])
	{
		// try enumerate through set
		NSSet *set = [obj valueForKey:propertyName];
		
		/*
		[set enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
			
			if ([obj respondsToSelector:@selector(debugQuickLookObject)])
			{
				NSView *view = [obj performSelector:@selector(debugQuickLookObject) withObject:nil];
//				NSImage *image = [self imageFromView:view];
//				[self addLineWithDescription:[self lineFromString:propertyName] image:image size:view.bounds.size];
				
				// try adding view directly
			}
		}];
		 */
		
		
		[self addLineWithDescription:[self lineFromString:propertyName] string:[set description]];
		return;
	}
	
	if ([class isSubclassOfClass:[NSArray class]])
	{
		NSArray *set = [obj valueForKey:propertyName];
		[self addLineWithDescription:[self lineFromString:propertyName] string:[set description]];
		return;
	}
	
	if ([class isSubclassOfClass:[NSColor class]])
	{
		NSColor *color = [obj valueForKey:propertyName];
		NSView *view = [self detailViewFromColor:color];
		[self addLineWithDescription:[self lineFromString:propertyName] view:view];
		
		return;
	}
	
	if ([class isSubclassOfClass:[NSError class]])
	{
		NSError *error = [obj valueForKey:propertyName];
		NSView *view = [self detailViewFromError:error];
		[self addLineWithDescription:[self lineFromString:propertyName] view:view];
		
		return;
	}
	
	if ([self addPrimitiveProperty:propertyName type:propertyType toObject:obj])
	{
		return;
	}

	if ([self propertyUsesProtocol:propertyType])	// delegate, uses protocol
	{
		id property = [[obj valueForKey:propertyName] description];
		[self addLineWithDescription:[self lineFromString:propertyName] string:property];
		return;
	}

	
	// probably something else, use description method
	id property = [[obj valueForKey:propertyName] description];
	[self addLineWithDescription:[self lineFromString:propertyName] string:property];
	
	return;
}

// TODO: use float if self.numberOfBitsPerColorComponent <= 0
- (NSView *)detailViewFromColor:(NSColor *)color
{
	if (self.numberOfBitsPerColorComponent < 1 || self.numberOfBitsPerColorComponent > 16) {
		@throw @"numberOfBitsPerColorComponent out of range (1 - 16)";
		return nil;
	}
	
	NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 120, 80)];
	[view setWantsLayer:YES];
	[[view layer] setMasksToBounds:YES];
	view.layer.borderColor = [[NSColor lightGrayColor] CGColor];
	view.layer.borderWidth = 1 / [[NSScreen mainScreen] backingScaleFactor];
	[view setNeedsDisplay:YES];

	NSView *colorView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 20, 80)];
	[colorView setWantsLayer:YES];
	[[colorView layer] setBackgroundColor:[color CGColor]];
	[view addSubview:colorView];
	
	NSTextField *red = [[NSTextField alloc] initWithFrame:NSMakeRect(25, 60, 80, 20)];
	[red setTextColor:[NSColor grayColor]];
	[red setBezeled:NO];
	[red setEditable:NO];
	[red setSelectable:YES];
	[red setFont:_propertyNameFont];
	[red setStringValue:[NSString stringWithFormat:@"Red:   %.0f", [color redComponent] * (pow(2, self.numberOfBitsPerColorComponent)-1)]];
	[view addSubview:red];
	
	NSTextField *green = [[NSTextField alloc] initWithFrame:NSMakeRect(25, 40, 80, 20)];
	[green setTextColor:[NSColor grayColor]];
	[green setBezeled:NO];
	[green setEditable:NO];
	[green setSelectable:YES];
	[green setFont:_propertyNameFont];
	[green setStringValue:[NSString stringWithFormat:@"Green: %.0f", [color greenComponent] * (pow(2, self.numberOfBitsPerColorComponent)-1)]];
	[view addSubview:green];
	
	NSTextField *blue = [[NSTextField alloc] initWithFrame:NSMakeRect(25, 20, 80, 20)];
	[blue setTextColor:[NSColor grayColor]];
	[blue setBezeled:NO];
	[blue setEditable:NO];
	[blue setSelectable:YES];
	[blue setFont:_propertyNameFont];
	[blue setStringValue:[NSString stringWithFormat:@"Blue:  %.0f", [color blueComponent] * (pow(2, self.numberOfBitsPerColorComponent)-1)]];
	[view addSubview:blue];
	
	NSTextField *alpha = [[NSTextField alloc] initWithFrame:NSMakeRect(25, 0, 80, 20)];
	[alpha setTextColor:[NSColor grayColor]];
	[alpha setBezeled:NO];
	[alpha setEditable:NO];
	[alpha setSelectable:YES];
	[alpha setFont:_propertyNameFont];
	[alpha setStringValue:[NSString stringWithFormat:@"Alpha: %.0f", [color alphaComponent] * (pow(2, self.numberOfBitsPerColorComponent)-1)]];
	[view addSubview:alpha];
	
	return view;
}

// TODO: title should resize, maybe use custom subclass with -layoutSubviews
- (NSView *)detailViewFromError:(NSError *)error
{
	if (!error) {
		return nil;
	}
	
	NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 300, 80)];
	[view setWantsLayer:YES];
	[[view layer] setMasksToBounds:YES];
	[[view layer] setBorderWidth:1.0f / [[NSScreen mainScreen] backingScaleFactor]];
	[view.layer setBorderColor:[[NSColor lightGrayColor] CGColor]];
	
	
	
	NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 10, 60, 60)];
	[imageView setImage:[NSImage imageNamed:NSImageNameCaution]];
	[imageView setImageScaling:NSImageScaleProportionallyUpOrDown];
	[imageView setEditable:NO];
	[imageView setEnabled:NO];
	[view addSubview:imageView];
	
	NSTextField *title = [[NSTextField alloc] initWithFrame:NSMakeRect(60, 55, 240, 20)];
	[title setEditable:NO];
	[title setSelectable:YES];
	[title setBezeled:NO];
	[title setStringValue:[error localizedDescription]];
	[title setFont:[NSFont boldSystemFontOfSize:12]];
	[view addSubview:title];
	
	NSTextField *info = [[NSTextField alloc] initWithFrame:NSMakeRect(60, 0, 240, 60)];
	[info setEditable:NO];
	[info setSelectable:YES];
	[info setBezeled:NO];
	[info setStringValue:[error localizedRecoverySuggestion]];
	[view addSubview:info];
	
	return view;
}

#pragma mark - Custom Type Properties

- (void)addDataProperty:(NSString *)property name:(NSString *)propertyName toObject:(id)obj
{
	if (_convertDataToImage && _propertyNameContains.count > 0)
	{
		BOOL contains = false;
		
		for (NSString *name in _propertyNameContains)
		{
			if ([propertyName rangeOfString:name options:NSCaseInsensitiveSearch].location != NSNotFound)
			{
				contains = true;
				break;
			}
		}
		
		
		if (contains)
		{
			// image Variable encoded as data
			NSData *data = (NSData *)property;
			NSImage *image = [[NSImage alloc] initWithData:data];
			
			if (image) {
				[self addLineWithDescription:[self lineFromString:propertyName] image:image];
				return;
			}
		}
	}

	NSData *data = (NSData *)property;
	NSString *string = [NSString stringWithFormat:@"%@ ...", [CocoaDebugView getSubData:data withRange:NSMakeRange(0, 20)]];
	[self addLineWithDescription:[self lineFromString:propertyName] string:string];
}

- (BOOL)addPrimitiveProperty:(NSString *)propertyName type:(NSString *)propertyType toObject:(id)obj
{
	if ([propertyType isEqualToString:@"char"])										// Char & bool
	{
		char character = [[obj valueForKey:propertyName] charValue];
		
		if (character == YES || character == true || character == NO || character == false) {
			[self addLineWithDescription:[self lineFromString:propertyName] boolean:character];
		} else {
			[self addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] string:[NSString stringWithFormat:@"%c", [[obj valueForKey:propertyName] charValue]]];
		}
		
		return YES;
	}
	
	if ([propertyType isEqualToString:@"int"])										// Int
	{
		NSNumber *number = [obj valueForKey:propertyName];
		[self addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] integer:[number integerValue]];
		return YES;
	}
	
	if ([propertyType isEqualToString:@"short"])									// Short
	{
		NSNumber *number = [obj valueForKey:propertyName];
		[self addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] integer:[number shortValue]];
		return YES;
	}
	
	if ([propertyType isEqualToString:@"long"])										// long
	{
		NSNumber *number = [obj valueForKey:propertyName];
		[self addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] integer:[number longValue]];
		return YES;
	}

	if ([propertyType isEqualToString:@"long long"])								// long long
	{
		NSNumber *number = [obj valueForKey:propertyName];
		[self addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] longnumber:[number longLongValue]];
		return YES;
	}
	
	if ([propertyType isEqualToString:@"unsigned char"])							// unsigned char
	{
		NSNumber *number = [obj valueForKey:propertyName];
		char mchar = [number charValue];
		NSString *string = [NSString stringWithFormat:@"%c", mchar];
		[self addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] string:string];
		return YES;
	}
	
	if ([propertyType isEqualToString:@"unsigned int"])								// unsigned Int
	{
		NSNumber *number = [obj valueForKey:propertyName];
		[self addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] unsignedInteger:[number unsignedIntegerValue]];
		return YES;
	}
	
	if ([propertyType isEqualToString:@"unsigned short"])							// unsigned Short
	{
		NSNumber *number = [obj valueForKey:propertyName];
		[self addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] integer:[number unsignedShortValue]];
		return YES;
	}
	
	if ([propertyType isEqualToString:@"unsigned long"])							// unsigned long
	{
		NSNumber *number = [obj valueForKey:propertyName];
		[self addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] unsignedInteger:[number unsignedLongValue]];
		return YES;
	}
	
	if ([propertyType isEqualToString:@"unsigned long long"])						// unsigned long long
	{
		NSNumber *number = [obj valueForKey:propertyName];
		[self addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] unsignedLongnumber:[number unsignedLongLongValue]];
		return YES;
	}
	
	if ([propertyType isEqualToString:@"float"])									// float
	{
		NSNumber *number = [obj valueForKey:propertyName];
		[self addLineWithDescription:[NSString stringWithFormat:@"%@:", propertyName] floating:[number floatValue]];
		return YES;
	}
	
	if ([propertyType isEqualToString:@"bool"])										// bool
	{
		NSNumber *number = [obj valueForKey:propertyName];
		[self addLineWithDescription:[self lineFromString:propertyName] boolean:[number boolValue]];
		return YES;
	}
	
	if ([propertyType isEqualToString:@"void"])										// char * (pointer)
	{
		NSString *string = [NSString stringWithFormat:@"%@", [obj valueForKey:propertyName]];
		[self addLineWithDescription:[self lineFromString:propertyName] string:string];
		return YES;
	}
	
	return NO;
}




#pragma mark - private

- (void)_addLineWithDescription:(NSString *)desc string:(NSString *)value leftColor:(NSColor *)leftColor rightColor:(NSColor *)rightColor leftFont:(NSFont *)lFont rightFont:(NSFont *)rfont
{
	[self removeDefaultApperance];
	
	// add left Label
	NSTextField *left = [self _addLeftLabel:desc color:leftColor font:lFont];
	
	// add right label
	NSTextField *right = [self defaultLabelWithString:value point:NSMakePoint(10 + leftWidth + 20, pos) textAlignment:NSLeftTextAlignment];
	[right setIdentifier:@"right"];
	[right setTextColor:rightColor];
	[right setFont:rfont];
	[right sizeToFit];
	
	if (right.frame.size.width > rightWidth) {
		rightWidth = right.frame.size.width;
	}
	
	
	[self synchroniseHeightOfView:left secondView:right];
	pos = pos + fmaxf(left.frame.size.height, right.frame.size.height) + _lineSpace;
	[self addSubview:right];
	[self resizeLeftTextViews];
	[self resizeRightTextViews];
	[self setFrame:NSMakeRect(0, 0, 10 + leftWidth + 20 + rightWidth + 10, pos)];
}

- (NSTextField *)_addLeftLabel:(NSString *)desc color:(NSColor *)color font:(NSFont *)font
{
	NSTextField *left = [self defaultLabelWithString:desc point:NSMakePoint(10, pos) textAlignment:NSRightTextAlignment];
	[left setStringValue:[left.stringValue stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[left.stringValue substringToIndex:1] capitalizedString]]];
	[left setIdentifier:@"left"];
	[left setTextColor:color];
	[left setFont:font];
	[left sizeToFit];
	
	
	if (left.frame.size.width > leftWidth) {
		leftWidth = left.frame.size.width;
	}
	[self addSubview:left];
	
	return left;
}



#pragma mark - Helpers

/**
 *	returns a string with ":" as last character
 */
- (NSString *)lineFromString:(NSString *)string
{
	return [NSString stringWithFormat:@"%@:", string];
}

- (BOOL)propertyUsesProtocol:(NSString *)property
{
	if (property.length > 2)
	{
		NSString *firstChar = [property substringToIndex:1];
		NSString *lastChar = [property substringFromIndex:property.length-1];
		
		if ([firstChar isEqualToString:@"<"] && [lastChar isEqualToString:@">"])
		{
			return YES;
		}
	}
	
	return NO;
}

- (NSImage *)imageFromView:(NSView *)view
{
	NSBitmapImageRep *imageRep = [view bitmapImageRepForCachingDisplayInRect:[view bounds]];
	[view cacheDisplayInRect:[view bounds] toBitmapImageRep:imageRep];
	NSImage *renderedImage = [[NSImage alloc] initWithSize:[imageRep size]];
	[renderedImage addRepresentation:imageRep];
	return renderedImage;
}

- (void)synchroniseHeightOfView:(NSView *)left secondView:(NSView *)right
{
	CGFloat height = fmaxf(left.frame.size.height, right.frame.size.height);
	[left setFrame:NSMakeRect(left.frame.origin.x, left.frame.origin.y, left.frame.size.width, height)];
	[right setFrame:NSMakeRect(right.frame.origin.x, right.frame.origin.y, right.frame.size.width, height)];
}

- (NSTextField *)defaultLabelWithString:(NSString *)string point:(NSPoint)point textAlignment:(NSTextAlignment)align
{
	NSTextField *textField = [[NSTextField alloc] initWithFrame:NSMakeRect(point.x, point.y, 100, 100)];
	[textField setBordered:NO];
	[textField setEditable:NO];
	[textField setSelectable:YES];
	[textField setAlignment:align];
	[textField setBackgroundColor:[NSColor clearColor]];

	if (string) {
		[textField setStringValue:string];
	}

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
