//
//  CocoaDebugView.h
//  CocoaDebugKit
//
//  Created by Patrick Kladek on 21.05.15.
//  Copyright (c) 2015 Patrick Kladek. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CocoaDebugView : NSView

@property (nonatomic) NSObject *obj;

@property (nonatomic) NSString *title;
@property (nonatomic) BOOL highlightKeywords;
@property (nonatomic) BOOL highlightNumbers;
@property (nonatomic) NSInteger lineSpace;

@property (nonatomic) NSColor *textColor;
@property (nonatomic) NSFont *textFont;

@property (nonatomic) NSColor *keywordColor;
@property (nonatomic) NSFont *keywordFont;

@property (nonatomic) NSColor *numberColor;
@property (nonatomic) NSFont *numberFont;

@property (nonatomic) NSColor *propertyNameColor;
@property (nonatomic) NSFont *propertyNameFont;

@property (nonatomic) NSColor *titleColor;
@property (nonatomic) NSFont *titleFont;

@property (nonatomic) NSColor *frameColor;
@property (nonatomic) NSColor *backgroundColor;
@property (nonatomic) NSSize imageSize;
@property (nonatomic) BOOL convertDataToImage;
@property (nonatomic) NSMutableArray *propertyNameContains;
@property (nonatomic) NSInteger numberOfBitsPerColorComponent;

@property (nonatomic) NSString *dateFormat;

@property (nonatomic) BOOL save;
@property (nonatomic) NSURL *saveUrl;
@property (nonatomic) BOOL saveAsPDF;


/**
 *	Creates a new debugView with no information
 */
+ (CocoaDebugView *)debugView;

/**
 *	Creates a new debugView with all properties from Object.
 *
 *	@param obj: the object for which the debugView will be created.
 *	@param include:	includes properties from Superclasses if true, otherwise only properties from current class.
 */
+ (CocoaDebugView *)debugViewWithAllPropertiesOfObject:(NSObject *)obj includeSuperclasses:(BOOL)include;

/**
 *	Creates a new debugView with all properties specified. Will also search in Superclasses.
 *
 *	@param properties: An array of properties (NSString) which will be added to the debugView.
 *	@param obj: the object for which the debugView will be created.
 */
+ (CocoaDebugView *)debugViewWithProperties:(NSArray *)properties ofObject:(NSObject *)obj;

/**
 *	Creates a new debugView with all properties from Object excluding named properties.
 *	@param properties: exclude properties from debugView.
 */
+ (CocoaDebugView *)debugViewWithExcludingProperties:(NSArray *)properties ofObject:(NSObject *)obj;


- (void)addAllPropertiesFromObject:(NSObject *)obj includeSuperclasses:(BOOL)include;
- (void)addProperties:(NSArray *)array fromObject:(NSObject *)obj;

- (void)addLineWithDescription:(NSString *)desc string:(NSString *)value;
- (void)addLineWithDescription:(NSString *)desc image:(NSImage *)image;
- (void)addLineWithDescription:(NSString *)desc date:(NSDate *)date;
- (void)addLineWithDescription:(NSString *)desc view:(NSView *)view;
- (void)addLineWithDescription:(NSString *)desc color:(NSColor *)color;
- (void)addLineWithDescription:(NSString *)desc error:(NSError *)error;
- (void)addLineWithDescription:(NSString *)desc data:(NSData *)data;

- (void)addLineWithDescription:(NSString *)desc integer:(NSInteger)integer;
- (void)addLineWithDescription:(NSString *)desc unsignedInteger:(NSUInteger)uinteger;
- (void)addLineWithDescription:(NSString *)desc longnumber:(long long)number;
- (void)addLineWithDescription:(NSString *)desc unsignedLongnumber:(unsigned long long)number;
- (void)addLineWithDescription:(NSString *)desc floating:(double)floating;
- (void)addLineWithDescription:(NSString *)desc boolean:(BOOL)boolean;


- (void)saveDebugView;
- (BOOL)saveDebugViewToUrl:(NSURL *)url;

- (NSImage *)imageFromView:(NSView *)view;

@end
