//
//  CocoaDebugView.m
//  CocoaDebugKit
//
//  Created by Patrick Kladek on 21.05.15.
//  Copyright (c) 2015 Patrick Kladek. All rights reserved.
//

#import "CocoaDebugView.h"
#import "CocoaDebugSettings.h"
#import "CocoaPropertyEnumerator.h"

#import "CPTextField+CPAdditions.h"
#import "CPView+CPAdditions.h"
#import "CPScreen+CPAdditions.h"
#import "CPColor+CPAdditions.h"
#import "CPImageView+CPAdditions.h"
#import "NSObject+CPAdditions.h"

#import <math.h>

/**
 *	@todo	- implement a protocol to support custom classes in debugView (simple representation like Color)
 *			- detailViewForError: find a way to resize the view based on its content
 *			- CoreData Relationships may not work
 */

@interface CocoaDebugView ()
{
	NSInteger pos;
	NSInteger leftWidth;
	NSInteger rightWidth;
	
	CPTextField *titleTextField;
	CPTextField *defaultTextField;
	
	CAGradientLayer *titleGradient;
	
	CocoaPropertyEnumerator *propertyEnumerator;
}

- (void)_addLineWithDescription:(NSString *)desc string:(NSString *)value leftColor:(CPColor *)leftColor rightColor:(CPColor *)rightColor leftFont:(CPFont *)lFont rightFont:(CPFont *)rfont;
+ (CPImage *)_imageFromView:(CPView *)view;

@end



@implementation CocoaDebugView


+ (instancetype)debugView
{
	return [[self alloc] init];
}

/**
 *	@note:	maybe could be simplyfied by calling '-debugViewWithProperties: ofObject:' by passing nil to array
 *	@note:	this would mean we ignore includeSuperclasses and adding parameter includeSuberclasses to 'debugViewWithProperties:ofObject:' would be confusing.
 */
+ (instancetype)debugViewWithAllPropertiesOfObject:(NSObject *)obj includeSuperclasses:(BOOL)include
{
	CocoaDebugView *view = [self debugView];
	[view setObj:obj];
	
	if (include) {
		[view setTitle:[view traceSuperClassesOfObject:obj]];
	} else {
		[view setTitle:NSStringFromClass([self class])];
	}
	
	[view addAllPropertiesFromObject:obj includeSuperclasses:include];
	
	if ([view save]) {
		[view saveDebugView];
	}

	return view;
}

+ (instancetype)debugViewWithProperties:(NSArray *)properties ofObject:(NSObject *)obj
{
	CocoaDebugView *view = [self debugView];
	[view setObj:obj];
	
	[view setTitle:[view traceSuperClassesOfObject:obj]];
	[view addProperties:properties fromObject:obj];
	
	if ([view save]) {
		[view saveDebugView];
	}
	
	return view;
}

+ (instancetype)debugViewWithExcludingProperties:(NSArray *)properties ofObject:(NSObject *)obj
{
	CocoaDebugView *view = [self debugView];
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
		
		
		[self setFrame:CPMakeRect(0, 0, 20, 55)];
		[self setTitle:@"CocoaDebugView"];
		[self setDefaultApperance];
		
		self.layer.masksToBounds = YES;
		
#if TARGET_OS_IPHONE
		[super setBackgroundColor:_backgroundColor];
#else
		self.layer = _layer;
		self.wantsLayer = YES;
		[self.layer setBackgroundColor:[_backgroundColor CGColor]];
#endif
		
		CPRect rect = CPMakeRect(0, 0, self.frame.size.width, 23);
		titleGradient = [CAGradientLayer layer];
		titleGradient.frame = rect;
		titleGradient.backgroundColor = [[CPColor whiteColor] CGColor];
		[self.layer insertSublayer:titleGradient atIndex:0];
	}
	return self;
}

- (void)drawRect:(CPRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
	// Uncomment this to resize view based on title lenght
//	if (titleTextField.frame.size.width + 20 > self.frame.size.width)	// +20 => | 10 --- label ----- 10 |
//	{
//		[self setFrame:CPMakeRect(self.frame.origin.x, self.frame.origin.y, titleTextField.frame.size.width + 20, self.frame.size.height)];
//	}
	
	[self.layer setCornerRadius:5];
	[self.layer setBorderColor:[_frameColor CGColor]];
	[self.layer setBorderWidth:1];
	[self.layer setBackgroundColor:[_backgroundColor CGColor]];
	
	
	
#if TARGET_OS_IPHONE

//	[super setBackgroundColor:_backgroundColor];
	
#else
	
//	[self.layer setBackgroundColor:[_backgroundColor CGColor]];

//	NSGradient *aGradient = [[NSGradient alloc] initWithStartingColor:startingColor endingColor:_frameColor];
//	[aGradient drawInRect:rect angle:90];
	
#endif
}

- (BOOL)isFlipped
{
	return YES;
}

- (void)layoutSubviews
{
	[self resizeGradientLayer];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
	[self resizeGradientLayer];
}

- (void)resizeGradientLayer
{
	CPColor *startingColor = [_frameColor colorWithAlphaComponent:0.75];
	titleGradient.colors = @[(id)startingColor.CGColor, (id)_frameColor.CGColor];
	titleGradient.frame = CPMakeRect(titleGradient.frame.origin.x, titleGradient.frame.origin.y, self.frame.size.width, titleGradient.frame.size.height);
}



#pragma mark - Apperance

- (void)setDefaultApperance
{
	[self removeDefaultApperance];
	
	defaultTextField = [[CPTextField alloc] initWithFrame:CPMakeRect(10, pos, self.frame.size.width - 20, 20)];
	[defaultTextField cp_setText:@"No Variables"];
	[defaultTextField setTextColor:[CPColor grayColor]];
	[defaultTextField cp_setAlignment:CPAlignmentCenter];
	[defaultTextField cp_setBordered:NO];
	[defaultTextField cp_setEditable:NO];
	[defaultTextField setBackgroundColor:[CPColor clearColor]];
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
	
	
#if TARGET_OS_IPHONE
	titleTextField = [self defaultLabelWithString:title point:CPMakePoint(10, 3) textAlignment:CPAlignmentLeft];
#else
	titleTextField = [self defaultLabelWithString:title point:CPMakePoint(10, 2) textAlignment:CPAlignmentLeft];
#endif
	
	[titleTextField setIdentifier:@"title"];
	[titleTextField setFont:_titleFont];
	[titleTextField setTextColor:_titleColor];
	[titleTextField sizeToFit];
	
	if (titleTextField.frame.size.width + 10 > self.frame.size.width) {
		[self setFrame:CPMakeRect(self.frame.origin.x, self.frame.origin.y, titleTextField.frame.size.width + 10, self.frame.size.height)];
	}
	
	[self addSubview:titleTextField];
	
	if (pos == 30) {
		[self setDefaultApperance];
	} else {
		[self removeDefaultApperance];
	}
	
	[self cp_update];
}

- (void)setColor:(CPColor *)color
{
	_frameColor = color;
	[self cp_update];
}




#pragma mark - Save

- (CPImage *)imageRepresentation
{
	return [[self class] _imageFromView:self];
}

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
		NSLog(@"%@", error);
		return;
	}
	
	NSString *className = [self.obj cp_className];
	NSDictionary *debuggedObjects = [[CocoaDebugSettings sharedSettings] debuggedObjects];
	NSInteger debuggedNr = [[debuggedObjects valueForKey:className] integerValue];
	debuggedNr++;
	[debuggedObjects setValue:[NSNumber numberWithInteger:debuggedNr] forKey:className];
	url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@ %li", className, (long)debuggedNr]];
	
	if (_saveAsPDF) {
		url = [url URLByAppendingPathExtension:@"pdf"];
	} else {
		url = [url URLByAppendingPathExtension:@"png"];
	}
	
	
	[self saveDebugViewToUrl:url];
}

- (BOOL)saveDebugViewToUrl:(NSURL *)url
{
#if TARGET_OS_IPHONE
	
	CPImage *image = [CocoaDebugView _imageFromView:self];
	NSData *data = [self dataFromImage:image];
	return [data writeToURL:url atomically:YES];
	
#else
	
	if ([[url pathExtension] isEqualToString:@"pdf"])
	{
		NSData *data = [self dataWithPDFInsideRect:[self bounds]];
		return [data writeToURL:url atomically:YES];
	}
	
	CPImage *image = [CocoaDebugView _imageFromView:self];
	NSData *data = [self dataFromImage:image];
	
	return [data writeToURL:url atomically:YES];
	
#endif
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




#pragma mark - Add Objects

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

- (void)addLineWithDescription:(NSString *)desc image:(CPImage *)image;
{
	if (!image) {
		[self addLineWithDescription:desc string:nil];
		return;
	}
	
	
	NSString *upperCaseDescription = [desc stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[desc substringToIndex:1] capitalizedString]];
	CPTextField *left = [self _addLeftLabel:upperCaseDescription color:_propertyNameColor font:_propertyNameFont];
	
	CPImageView *imageView = [[CPImageView alloc] initWithFrame:CPMakeRect(10 + leftWidth + 20, pos, _imageSize.width, _imageSize.height)];
	[imageView setImage:image];
	[imageView setIdentifier:@"rightImage"];
	[imageView cp_setImageScaling:CPImageScaleProportionallyUpOrDown];
	[self synchroniseRightWidthFromView:imageView];
	[self addSubview:imageView];
	
	[self synchroniseHeightOfView:left secondView:imageView];
	pos = pos + imageView.frame.size.height + _lineSpace;
	[self resizeLeftTextViews];
	[self resizeRightTextViews];
	[self setFrame:CPMakeRect(0, 0, 10 + leftWidth + 20 + rightWidth + 10, pos)];
}

- (void)addLineWithDescription:(NSString *)desc date:(NSDate *)date
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:_dateFormat];
	NSString *dateString = [dateFormatter stringFromDate:date];
	[self addLineWithDescription:desc string:dateString];
}

- (void)addLineWithDescription:(NSString *)desc view:(CPView *)view
{
	if (!view) {
		[self addLineWithDescription:desc string:nil];
		return;
	}
	
	
	// add left label
	CPTextField *left = [self _addLeftLabel:desc color:_propertyNameColor font:_propertyNameFont];
		
	// add right view
	[view setFrame:CPMakeRect(10 + leftWidth + 20, pos, view.frame.size.width, view.frame.size.height)];
	[view setIdentifier:@"rightImage"];
	
	
	[self synchroniseRightWidthFromView:view];
	
	pos = pos + fmaxf(left.frame.size.height, view.frame.size.height) + _lineSpace;
	[self addSubview:view];
	[self resizeLeftTextViews];
	[self resizeRightTextViews];
	[self setFrame:CPMakeRect(0, 0, 10 + leftWidth + 20 + rightWidth + 10, pos)];
}

- (void)addLineWithDescription:(NSString *)desc color:(CPColor *)color
{
	if (!color) {
		[self addLineWithDescription:desc string:nil];
		return;
	}
	
	CPView *view = [self detailViewFromColor:color];
	[self addLineWithDescription:desc view:view];
}

- (void)addLineWithDescription:(NSString *)desc error:(NSError *)error
{
	if (!error) {
		[self addLineWithDescription:desc string:nil];
		return;
	}
	
	CPView *view = [self detailViewFromError:error];
	[self addLineWithDescription:desc view:view];
}

- (void)addLineWithDescription:(NSString *)desc data:(NSData *)data
{
	if (!data) {
		[self addLineWithDescription:desc string:nil];
		return;
	}
	
	if (data.length > 20) {
		NSData *clippedData = [data subdataWithRange:NSMakeRange(0, 20)];
		[self addLineWithDescription:desc string:[NSString stringWithFormat:@"%@ ...", clippedData]];
	} else {
		[self addLineWithDescription:desc string:[NSString stringWithFormat:@"%@ ...", data]];
	}
}



#pragma mark - Add Scalar Properties

- (void)addLineWithDescription:(NSString *)desc integer:(NSInteger)integer
{
	NSString *number = [NSString stringWithFormat:@"%li", (long)integer];
	
	if (_highlightNumbers) {
		[self _addLineWithDescription:desc string:number leftColor:_propertyNameColor rightColor:_numberColor leftFont:_propertyNameFont rightFont:_numberFont];
	} else {
		[self _addLineWithDescription:desc string:number leftColor:_propertyNameColor rightColor:_textColor leftFont:_propertyNameFont rightFont:_textFont];
	}
}

- (void)addLineWithDescription:(NSString *)desc unsignedInteger:(NSUInteger)uinteger
{
	NSString *number = [NSString stringWithFormat:@"%lu", (unsigned long)uinteger];
	
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
	NSString *result = boolean ? @"YES" : @"NO";
	
	if (_highlightKeywords) {
		[self _addLineWithDescription:desc string:result leftColor:_propertyNameColor rightColor:_keywordColor leftFont:_propertyNameFont rightFont:_keywordFont];
	} else {
		[self _addLineWithDescription:desc string:result leftColor:_propertyNameColor rightColor:_textColor leftFont:_propertyNameFont rightFont:_keywordFont];
	}
}

- (void)addSeperator
{
	// TODO: draw dashed line here
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
	
	if ([class isSubclassOfClass:[NSString class]])
	{
		NSString *property = [obj valueForKey:propertyName];
		[self addLineWithDescription:[self lineFromString:propertyName] string:property];
		return;
	}
	
	if ([class isSubclassOfClass:[NSData class]])
	{
		NSData *property = [obj valueForKey:propertyName];
		[self addDataProperty:property name:propertyName toObject:obj];
		return;
	}
	
	if ([class isSubclassOfClass:[NSDate class]])
	{
		id property = [obj valueForKey:propertyName];
		[self addLineWithDescription:[self lineFromString:propertyName] date:property];
		return;
	}
	
	if ([class isSubclassOfClass:[CPImage class]])
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
		NSSet *set = [obj valueForKey:propertyName];
		[self addLineWithDescription:[self lineFromString:propertyName] string:[set description]];
		return;
	}
	
	if ([class isSubclassOfClass:[NSArray class]])
	{
		NSArray *array = [obj valueForKey:propertyName];
		[self addLineWithDescription:[self lineFromString:propertyName] string:[array description]];
		return;
	}
	
	if ([class isSubclassOfClass:[NSDictionary class]])
	{
		NSDictionary *dictionary = [obj valueForKey:propertyName];
		[self addLineWithDescription:[self lineFromString:propertyName] string:[dictionary description]];
		return;
	}
	
	if ([class isSubclassOfClass:[CPColor class]])
	{
		CPColor *color = [obj valueForKey:propertyName];
		[self addLineWithDescription:[self lineFromString:propertyName] color:color];
		return;
	}
	
	if ([class isSubclassOfClass:[NSError class]])
	{
		NSError *error = [obj valueForKey:propertyName];
		[self addLineWithDescription:[self lineFromString:propertyName] error:error];
		return;
	}

	if ([self propertyUsesProtocol:propertyType])	// delegate, uses protocol
	{
		id property = [[obj valueForKey:propertyName] description];
		[self addLineWithDescription:[self lineFromString:propertyName] string:property];
		return;
	}
	
	if ([class isSubclassOfClass:[NSNumber class]]) {
		NSNumber *number = [obj valueForKey:propertyName];
		[self _addLineWithDescription:[self lineFromString:propertyName] string:[number descriptionWithLocale:nil] leftColor:_propertyNameColor rightColor:_numberColor leftFont:_propertyNameFont rightFont:_numberFont];
		return;

	}

	
	// probably something else, use description method
	id property = [[obj valueForKey:propertyName] description];
	[self addLineWithDescription:[self lineFromString:propertyName] string:property];
	
	return;
}

- (CPView *)detailViewFromColor:(CPColor *)color
{
	if (self.numberOfBitsPerColorComponent < 0 || self.numberOfBitsPerColorComponent > 16) {
		@throw @"numberOfBitsPerColorComponent out of range (0 - 16)";
		return nil;
	}
	
	CPView *view = [[CPView alloc] initWithFrame:CPMakeRect(0, 0, 140, 80)];
	[view cp_setWantsLayer:YES];
	[[view layer] setMasksToBounds:YES];
	view.layer.borderColor = [[CPColor lightGrayColor] CGColor];
	view.layer.borderWidth = 1 / [[CPScreen mainScreen] cp_scale];
	[view cp_update];

	CPView *colorView = [[CPView alloc] initWithFrame:CPMakeRect(0, 0, 20, 80)];
	[colorView cp_setWantsLayer:YES];
	[[colorView layer] setBackgroundColor:[color CGColor]];
	[view addSubview:colorView];
	
	CPTextField *red = [[CPTextField alloc] initWithFrame:CPMakeRect(25, 60, 100, 20)];
	[red setTextColor:[CPColor grayColor]];
	[red cp_setBordered:NO];
	[red cp_setEditable:NO];
	[red cp_setSelectable:YES];
	[red setFont:_propertyNameFont];
	if (self.numberOfBitsPerColorComponent == 0) {
		[red cp_setText:[NSString stringWithFormat:@"Red:   %.3f", [color cp_redComponent]]];
	} else {
		[red cp_setText:[NSString stringWithFormat:@"Red:   %.0f", [color cp_redComponent] * (pow(2, self.numberOfBitsPerColorComponent)-1)]];
	}
	[view addSubview:red];
	
	CPTextField *green = [[CPTextField alloc] initWithFrame:CPMakeRect(25, 40, 100, 20)];
	[green setTextColor:[CPColor grayColor]];
	[green cp_setBezeled:NO];
	[green cp_setEditable:NO];
	[green cp_setSelectable:YES];
	[green setFont:_propertyNameFont];
	if (self.numberOfBitsPerColorComponent == 0) {
		[green cp_setText:[NSString stringWithFormat:@"Green: %.3f", [color cp_greenComponent]]];
	} else {
		[green cp_setText:[NSString stringWithFormat:@"Green: %.0f", [color cp_greenComponent] * (pow(2, self.numberOfBitsPerColorComponent)-1)]];
	}
	[view addSubview:green];
	
	CPTextField *blue = [[CPTextField alloc] initWithFrame:CPMakeRect(25, 20, 100, 20)];
	[blue setTextColor:[CPColor grayColor]];
	[blue cp_setBezeled:NO];
	[blue cp_setEditable:NO];
	[blue cp_setSelectable:YES];
	[blue setFont:_propertyNameFont];
	if (self.numberOfBitsPerColorComponent == 0) {
		[blue cp_setText:[NSString stringWithFormat:@"Blue:  %.3f", [color cp_blueComponent]]];
	} else {
		[blue cp_setText:[NSString stringWithFormat:@"Blue:  %.0f", [color cp_blueComponent] * (pow(2, self.numberOfBitsPerColorComponent)-1)]];
	}
	[view addSubview:blue];
	
	CPTextField *alpha = [[CPTextField alloc] initWithFrame:CPMakeRect(25, 0, 100, 20)];
	[alpha setTextColor:[CPColor grayColor]];
	[alpha cp_setBezeled:NO];
	[alpha cp_setEditable:NO];
	[alpha cp_setSelectable:YES];
	[alpha setFont:_propertyNameFont];
	if (self.numberOfBitsPerColorComponent == 0) {
		[alpha cp_setText:[NSString stringWithFormat:@"Alpha: %.3f", [color cp_alphaComponent]]];
	} else {
		[alpha cp_setText:[NSString stringWithFormat:@"Alpha: %.0f", [color cp_alphaComponent] * (pow(2, self.numberOfBitsPerColorComponent)-1)]];
	}
	[view addSubview:alpha];
	
	[red sizeToFit];
	[green sizeToFit];
	[blue sizeToFit];
	[alpha sizeToFit];
	CGFloat width = fmax(fmax(red.frame.size.width, green.frame.size.width), fmax(blue.frame.size.width, alpha.frame.size.width));
	view.frame = CPMakeRect(0, 0, width + colorView.frame.size.width + 5, 80);
	
	return view;
}

/// @todo title should resize, maybe use custom subclass with -layoutSubviews
- (CPView *)detailViewFromError:(NSError *)error
{
	if (!error) {
		return nil;
	}
	
	CPView *view = [[CPView alloc] initWithFrame:CPMakeRect(0, 0, 300, 80)];
	[view cp_setWantsLayer:YES];
	[[view layer] setMasksToBounds:YES];
	[[view layer] setBorderWidth:1.0f / [[CPScreen mainScreen] cp_scale]];
	[view.layer setBorderColor:[[CPColor lightGrayColor] CGColor]];
	
	CPImageView *imageView = [[CPImageView alloc] initWithFrame:CPMakeRect(0, 10, 60, 60)];
	NSURL *imageURL = [[NSBundle bundleForClass:[CocoaDebugView class]] URLForResource:@"AlertCautionIcon" withExtension:@"icns"];
	NSData *data = [NSData dataWithContentsOfURL:imageURL];
	[imageView setImage:[[CPImage alloc] initWithData:data]];
	[imageView cp_setImageScaling:CPImageScaleProportionallyUpOrDown];
	[imageView cp_setEditable:NO];
	[view addSubview:imageView];
	
	CPTextField *title = [[CPTextField alloc] initWithFrame:CPMakeRect(60, 55, 240, 20)];
	[title cp_setEditable:NO];
	[title cp_setSelectable:YES];
	[title cp_setBezeled:NO];
	[title cp_setText:[error localizedDescription]];
	[title setFont:[CPFont boldSystemFontOfSize:12]];
	[view addSubview:title];
	
	CPTextField *info = [[CPTextField alloc] initWithFrame:CPMakeRect(60, 0, 240, 60)];
	[info cp_setEditable:NO];
	[info cp_setSelectable:YES];
	[info cp_setBezeled:NO];
	[info cp_setText:[error localizedRecoverySuggestion]];
	[view addSubview:info];
	
	return view;
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

#pragma mark - Custom Type Properties

- (void)addDataProperty:(NSData *)data name:(NSString *)propertyName toObject:(id)obj
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
			// NSImage encoded as data
			CPImage *image = [[CPImage alloc] initWithData:data];
			
			if (image) {
				[self addLineWithDescription:[self lineFromString:propertyName] image:image];
				return;
			}
		}
	}

	[self addLineWithDescription:[self lineFromString:propertyName] data:data];

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




#pragma mark - Private

- (void)_addLineWithDescription:(NSString *)desc string:(NSString *)value leftColor:(CPColor *)leftColor rightColor:(CPColor *)rightColor leftFont:(CPFont *)lFont rightFont:(CPFont *)rfont
{
	[self removeDefaultApperance];
	
	// add left Label
	CPTextField *left = [self _addLeftLabel:desc color:leftColor font:lFont];
	
	// add right label
	CPTextField *right = [self _addRightLabel:value color:rightColor font:rfont];
	
	[self synchroniseHeightOfView:left secondView:right];
	pos = pos + fmaxf(left.frame.size.height, right.frame.size.height) + _lineSpace;
	[self resizeLeftTextViews];
	[self resizeRightTextViews];
	[self setFrame:CPMakeRect(0, 0, 10 + leftWidth + 20 + rightWidth + 10, pos)];
}

- (CPTextField *)_addLeftLabel:(NSString *)desc color:(CPColor *)color font:(CPFont *)font
{
	CPTextField *left = [self defaultLabelWithString:desc point:CPMakePoint(10, pos) textAlignment:CPAlignmentRight];
	[left cp_setText:[left.cp_Text stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[left.cp_Text substringToIndex:1] capitalizedString]]];
	[left setIdentifier:@"left"];
	[left setTextColor:color];
	[left setFont:font];
	[left sizeToFit];
	
	[self synchroniseLeftWidthFromView:left];
	[self addSubview:left];
	
	return left;
}

- (CPTextField *)_addRightLabel:(NSString *)desc color:(CPColor *)color font:(CPFont *)font
{
	CPTextField *right = [self defaultLabelWithString:desc point:CPMakePoint(10 + leftWidth + 20, pos) textAlignment:CPAlignmentLeft];
	[right setIdentifier:@"right"];
	[right setTextColor:color];
	[right setFont:font];
	
	[self addSubview:right];
	[right sizeToFit];
	[self synchroniseRightWidthFromView:right];
	
	return right;
}

+ (CPImage *)_imageFromView:(CPView *)view
{
#if TARGET_OS_IPHONE
	UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
	[view.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return img;
#else
	NSBitmapImageRep *imageRep = [view bitmapImageRepForCachingDisplayInRect:[view bounds]];
	[view cacheDisplayInRect:[view bounds] toBitmapImageRep:imageRep];
	NSImage *renderedImage = [[NSImage alloc] initWithSize:[imageRep size]];
	[renderedImage addRepresentation:imageRep];
	return renderedImage;
#endif
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

- (NSData *)dataFromImage:(CPImage *)image
{
#if TARGET_OS_IPHONE
	return UIImagePNGRepresentation(image);
#else
	CGImageRef cgRef = [image CGImageForProposedRect:NULL context:nil hints:nil];
	NSBitmapImageRep *newRep = [[NSBitmapImageRep alloc] initWithCGImage:cgRef];
	[newRep setSize:[image size]];   // if you want the same resolution
	return [newRep representationUsingType:NSPNGFileType properties:nil];
#endif
}

- (void)synchroniseHeightOfView:(CPView *)left secondView:(CPView *)right
{
	CGFloat height = fmaxf(left.frame.size.height, right.frame.size.height);
	[left setFrame:CPMakeRect(left.frame.origin.x, left.frame.origin.y, left.frame.size.width, height)];
	[right setFrame:CPMakeRect(right.frame.origin.x, right.frame.origin.y, right.frame.size.width, height)];
}

- (void)synchroniseRightWidthFromView:(CPView *)view
{
	CGFloat newWidth = view.frame.size.width;
	
	if (newWidth > rightWidth) {
		rightWidth = newWidth;
	}
}

- (void)synchroniseLeftWidthFromView:(CPView *)view
{
	CGFloat newWidth = view.frame.size.width;
	
	if (newWidth > leftWidth) {
		leftWidth = newWidth;
	}
}

- (CPTextField *)defaultLabelWithString:(NSString *)string point:(CPPoint)point textAlignment:(CPTextAlignment)align
{
	CPTextField *textField = [[CPTextField alloc] initWithFrame:CPMakeRect(point.x, point.y, 5000, 5000)];
//	textField.frame.size = [textField sizeThatFits:[CGSizeMake(5000.0, 5000.0)]]		// Works in Swift
	[textField setPreferredMaxLayoutWidth:5000];
	[textField cp_setBordered:NO];
	[textField cp_setEditable:NO];
	[textField cp_setSelectable:YES];
	[textField cp_setAlignment:align];
	[textField setBackgroundColor:[CPColor clearColor]];
	[textField setTextColor:[CPColor blackColor]];
	[textField cp_setNumberOfLines:0];
	
	if (string) {
		[textField cp_setText:string];
	} else {
		NSLog(@"[CocoaDebugKit] failed to set nil value to NSTextField (%s, %s)", __FILE__, __PRETTY_FUNCTION__);
		[textField cp_setText:@"nil"];
	}

	return textField;
}

- (void)resizeLeftTextViews
{
	for (CPView *view in self.subviews)
	{
		if ([[view identifier] isEqualToString:@"left"])
		{
			[view setFrame:CPMakeRect(10, view.frame.origin.y, leftWidth + 10, view.frame.size.height)];
		}
	}
}

- (void)resizeRightTextViews
{
	for (CPView *view in self.subviews)
	{
		if ([[view identifier] isEqualToString:@"right"])
		{
			// need an extra pixel to prevent line wrap. Only on iOS thow
			[view setFrame:CPMakeRect(10 + leftWidth + 20, view.frame.origin.y, rightWidth + 1, view.frame.size.height)];
		}
		
		if ([[view identifier] isEqualToString:@"rightImage"])
		{
			[view setFrame:CPMakeRect(10 + leftWidth + 20, view.frame.origin.y, view.frame.size.width, view.frame.size.height)];
		}
	}
}

@end