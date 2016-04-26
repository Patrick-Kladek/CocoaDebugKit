//
//  pkDebugView.h
//  pkDebugFramework
//
//  Created by Patrick Kladek on 21.05.15.
//  Copyright (c) 2015 Patrick Kladek. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface pkDebugView : NSView

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


+ (pkDebugView *)debugView;
+ (pkDebugView *)debugViewWithAllPropertiesOfObject:(NSObject *)obj includeSubclasses:(BOOL)include;
+ (pkDebugView *)debugViewWithProperties:(NSString *)properties ofObject:(NSObject *)obj;




- (void)addProperties:(NSString *)string fromObject:(NSObject *)obj;
- (void)addAllPropertiesFromObject:(NSObject *)obj;

- (void)addLineWithDescription:(NSString *)desc string:(NSString *)value;
- (void)addLineWithDescription:(NSString *)desc integer:(NSInteger)integer;
- (void)addLineWithDescription:(NSString *)desc unsignedInteger:(NSUInteger)uinteger;
- (void)addLineWithDescription:(NSString *)desc longnumber:(long long)number;
- (void)addLineWithDescription:(NSString *)desc unsignedLongnumber:(unsigned long long)number;
- (void)addLineWithDescription:(NSString *)desc floating:(double)floating;
- (void)addLineWithDescription:(NSString *)desc boolean:(BOOL)boolean;
- (void)addLineWithDescription:(NSString *)desc image:(NSImage *)image;

@end
