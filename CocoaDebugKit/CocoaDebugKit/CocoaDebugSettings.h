//
//  CocoaDebugSettings.h
//  CocoaDebugKit
//
//  Created by Patrick Kladek on 19.04.16.
//  Copyright (c) 2016 Patrick Kladek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaDebugKit/CrossPlatformDefinitions.h>


@interface CocoaDebugSettings: NSObject

+ (CocoaDebugSettings *)sharedSettings;

@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) BOOL hasSettings;

@property (nonatomic) NSInteger lineSpace;
@property (nonatomic) BOOL highlightKeywords;
@property (nonatomic) BOOL highlightNumbers;

@property (nonatomic) CPColor *textColor;
@property (nonatomic) CPFont *textFont;

@property (nonatomic) CPColor *keywordColor;
@property (nonatomic) CPFont *keywordFont;

@property (nonatomic) CPColor *numberColor;
@property (nonatomic) CPFont *numberFont;

@property (nonatomic) CPColor *propertyNameColor;
@property (nonatomic) CPFont *propertyNameFont;

@property (nonatomic) CPColor *titleColor;
@property (nonatomic) CPFont *titleFont;

@property (nonatomic) CPColor *frameColor;
@property (nonatomic) CPColor *backgroundColor;
@property (nonatomic) CPSize imageSize;

@property (nonatomic) NSString *dateFormat;

@property (nonatomic) CGSize maxSizeOfField;
@property (nonatomic) NSNumber *maxDataLenght;
@property (nonatomic) BOOL convertDataToImage;
@property (nonatomic) NSArray *propertyNameContains;

@property (nonatomic) BOOL save;
@property (nonatomic) NSURL *saveUrl;
@property (nonatomic) BOOL saveAsPDF;

@property (nonatomic) NSMutableDictionary *debuggedObjects; // used for numbering debugged views & descriptions

@property (nonatomic) NSInteger numberOfBitsPerColorComponent;

- (BOOL)loadSettings:(NSURL *)url;
- (BOOL)saveSettings:(NSURL *)url;

@end
