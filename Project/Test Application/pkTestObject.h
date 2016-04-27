//
//  pkTestObject.h
//  pkDebugFramework
//
//  Created by Patrick Kladek on 04.08.15.
//  Copyright (c) 2015 Patrick Kladek. All rights reserved.
//

#import <Foundation/Foundation.h>

@class pkTestObject;

@protocol pkTestObjectDelegate <NSObject>

-(void)smt;

@end




@interface pkTestObject : NSObject

@property (nonatomic, weak) id<pkTestObjectDelegate> delegate;

@property (nonatomic) NSData *dataImage;

@property (nonatomic) NSDate *date;
@property (nonatomic) NSImage *image;
@property (nonatomic) id prop;

@property (nonatomic) NSSet *set;

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *test;

@property (nonatomic, getter=isCheck) BOOL check;
@property (nonatomic) unsigned char ccheck;
@property (nonatomic) int inum;
@property (nonatomic) long lnum;

@property (nonatomic) NSURL *url;



@property (nonatomic) pkTestObject *object;

- (id)debugQuickLookObject;

@end
