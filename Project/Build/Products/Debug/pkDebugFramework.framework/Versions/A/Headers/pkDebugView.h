//
//  pkDebugView.h
//  pkDebugFramework
//
//  Created by Patrick Kladek on 21.05.15.
//  Copyright (c) 2015 Patrick Kladek. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface pkDebugView : NSView
{
	NSInteger pos;
	NSInteger leftWidth;
	NSInteger rightWidth;
	
	NSTextField *titleTextField;
}

@property (nonatomic) NSString *title;
@property (nonatomic) BOOL highlightKeywords;
@property (nonatomic) BOOL highlightNumbers;
@property (nonatomic) NSInteger space;
@property (nonatomic) NSColor *color;
@property (nonatomic) NSColor *keywordColor;
@property (nonatomic) NSColor *numberColor;


+ (pkDebugView *)debugView;
+ (pkDebugView *)debugViewWithAllPropertiesOfObject:(NSObject *)obj;

- (void)addLineWithDescription:(NSString *)desc string:(NSString *)value;
- (void)addLineWithDescription:(NSString *)desc integer:(NSInteger)integer;
- (void)addLineWithDescription:(NSString *)desc unsignedInteger:(NSUInteger)uinteger;
- (void)addLineWithDescription:(NSString *)desc longnumber:(long long)number;
- (void)addLineWithDescription:(NSString *)desc unsignedLongnumber:(unsigned long long)number;
- (void)addLineWithDescription:(NSString *)desc floating:(double)floating;
- (void)addLineWithDescription:(NSString *)desc boolean:(BOOL)boolean;

@end
