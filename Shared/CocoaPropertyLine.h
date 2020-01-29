//
//  CocoaPropertyLine.h
//  CocoaTouchDebugKit
//
//  Created by Patrick Kladek on 25.05.17.
//  Copyright (c) 2017 Patrick Kladek. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CocoaPropertyLine : NSObject

@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *value;

+ (CocoaPropertyLine *)lineWithType:(NSString *)type name:(NSString *)name value:(NSString *)value;
- (instancetype)initWithType:(NSString *)type name:(NSString *)name value:(NSString *)value;

@end
