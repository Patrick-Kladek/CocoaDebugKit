//
//  pkTestObject.h
//  pkDebugFramework
//
//  Created by Patrick Kladek on 04.08.15.
//  Copyright (c) 2015 Patrick Kladek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface pkTestObject : NSObject

@property (nonatomic) NSData *data;

@property (nonatomic) NSDate *date;
@property (nonatomic) NSImage *image;
@property (nonatomic) id prop;

@property (nonatomic) NSSet *set;

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *test;

@property (nonatomic) BOOL check;
@property (nonatomic) unsigned char ccheck;
@property (nonatomic) int inum;
@property (nonatomic) long lnum;

- (id)debugQuickLookObject;

@end
