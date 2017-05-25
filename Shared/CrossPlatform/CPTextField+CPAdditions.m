//
//  CPTextField+CPAdditions.m
//  CocoaDebugKit
//
//  Created by Patrick Kladek on 20.05.17.
//  Copyright (c) 2017 Patrick Kladek. All rights reserved.
//

#import "CPTextField+CPAdditions.h"
@import ObjectiveC.runtime;


#if TARGET_OS_IPHONE
	@implementation UILabel (CPAdditions)
#else
	@implementation NSTextField (CPAdditions)
#endif


#if TARGET_OS_IPHONE

static char kIdentifier;

- (void)setIdentifier:(NSString *)identifier
{
	objc_setAssociatedObject(self, &kIdentifier, identifier, OBJC_ASSOCIATION_COPY);
}

- (NSString *)identifier
{
	return objc_getAssociatedObject(self, &kIdentifier);
}

#endif


- (void)cp_setText:(NSString *)string
{
#if TARGET_OS_IPHONE
	[self setText:string];
#else
	[self setStringValue:string];
#endif
}

- (NSString *)cp_Text
{
#if TARGET_OS_IPHONE
	return [self text];
#else
	return [self stringValue];
#endif
}


- (void)cp_setAlignment:(CPTextAlignment)alignment
{
#if TARGET_OS_IPHONE
	[self setTextAlignment:(NSTextAlignment)alignment];
#else
	[self setAlignment:(NSTextAlignment)alignment];
#endif
}

- (void)cp_setBordered:(BOOL)border
{
#if !TARGET_OS_IPHONE
	[self setBordered:border];
#endif
}

- (void)cp_setBezeled:(BOOL)bezel
{
#if TARGET_OS_IPHONE
	// No bezel on iOS
#else
	[self setBezeled:bezel];
#endif
}

- (void)cp_setEditable:(BOOL)editable
{
#if !TARGET_OS_IPHONE
	[self setEditable:editable];
#endif
}

- (void)cp_setSelectable:(BOOL)selectable
{
#if TARGET_OS_IPHONE
	// Selection not availible in iOS
#else
	[self setSelectable:selectable];
#endif
}


- (void)cp_setNumberOfLines:(NSInteger)numberOfLines
{
#if TARGET_OS_IPHONE
	[self setNumberOfLines:0];
#endif
}

@end
