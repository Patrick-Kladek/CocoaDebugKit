//
//  Person.h
//  pkDebugFramework
//
//  Created by Patrick Kladek on 18.04.16.
//  Copyright (c) 2016 Patrick Kladek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@property (nonatomic) NSImage *image;
@property (nonatomic) NSString *firstName;
@property (nonatomic) NSString *lastName;
@property (nonatomic) NSDate *birthday;

- (id)debugQuickLookObject;

@end
