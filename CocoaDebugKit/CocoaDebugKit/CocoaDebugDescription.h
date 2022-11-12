//
//  CocoaDebugDescription.h
//  CocoaDebugKit
//
//  Created by Patrick Kladek on 19.04.16.
//  Copyright (c) 2016 Patrick Kladek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaDebugKit/CrossPlatformDefinitions.h>


@interface CocoaDebugDescription : NSObject

@property (nonatomic, readonly) NSObject *obj;
@property (nonatomic) NSNumber *dataMaxLenght;

@property (nonatomic) BOOL save;
@property (nonatomic) NSURL *saveUrl;

+ (CocoaDebugDescription *)debugDescription;
+ (CocoaDebugDescription *)debugDescriptionForObject:(NSObject *)obj;

- (void)addAllPropertiesFromObject:(NSObject *)obj;
- (void)addDescriptionLine:(CocoaPropertyLine *)line;

- (NSString *)stringRepresentation;

- (void)saveDebugDescription;
- (BOOL)saveDebugDescriptionToUrl:(NSURL *)url error:(NSError **)error;

@end
