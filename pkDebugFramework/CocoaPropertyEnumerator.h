//
//  pkPropertyEnumerator.h
//  pkDebugFramework
//
//  Created by Patrick Kladek on 25.04.16.
//  Copyright (c) 2016 Patrick Kladek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CocoaPropertyEnumerator : NSObject

- (void)enumerateProperties:(Class)objectClass allowed:(NSString *)allowed block:(void (^)(NSString *type, NSString *name))callbackBlock;

- (NSString *)propertyTypeFromName:(NSString *)name object:(NSObject *)obj;

@end
