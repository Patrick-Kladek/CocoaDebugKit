//
//  CocoaDebugDescription.h
//  CocoaDebugKit
//
//  Created by Patrick Kladek on 19.04.16.
//  Copyright (c) 2016 Patrick Kladek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CocoaDebugDescription : NSObject


@property (nonatomic) NSObject *obj;
@property (nonatomic) NSNumber *dataMaxLenght;

@property (nonatomic) BOOL save;
@property (nonatomic) NSURL *saveUrl;



- (NSString *)descriptionForObject:(NSObject *)object;



- (void)saveDebugDescription;
- (BOOL)saveDebugDescriptionToUrl:(NSURL *)url;

@end
