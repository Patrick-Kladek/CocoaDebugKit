//
//  TestObject.h
//  CocoaDebugFramework
//
//  Created by Patrick Kladek on 04.08.15.
//  Copyright (c) 2015 Patrick Kladek. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TestObject;

@protocol TestObjectDelegate <NSObject>

-(void)smt;

@end




@interface TestObject : NSObject

@property (nonatomic, weak) id<TestObjectDelegate> delegate;

@property (nonatomic) NSData *dataImage;

@property (nonatomic) NSDate *date;
@property (nonatomic) NSImage *image;
@property (nonatomic) id prop;

@property (nonatomic) NSSet *set;

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *test;

@property (nonatomic, getter=isCheck) BOOL check_bool;
@property (nonatomic) unsigned char ccheck;
@property (nonatomic) int inum;
@property (nonatomic) long lnum;

@property (nonatomic) NSURL *url;



@property (nonatomic) TestObject *object;

- (id)debugQuickLookObject;

@end
