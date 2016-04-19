//
//  pkDebugSettings.h
//  pkDebugFramework
//
//  Created by Patrick Kladek on 19.04.16.
//  Copyright (c) 2016 Patrick Kladek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>


@interface pkDebugSettings : NSObject

+ (pkDebugSettings *)sharedSettings;

@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) BOOL hasSettings;



@property (nonatomic) NSInteger lineSpace;
@property (nonatomic) BOOL highlightKeywords;
@property (nonatomic) BOOL highlightNumbers;


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






- (BOOL)loadSettings:(NSURL *)url;
- (BOOL)saveSettings:(NSURL *)url;

@end
