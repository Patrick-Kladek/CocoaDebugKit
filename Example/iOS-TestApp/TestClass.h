//
//  TestClass.h
//  CocoaDebugKit
//
//  Created by Patrick Kladek on 22.05.17.
//  Copyright (c) 2017 Patrick Kladek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestClass : NSObject

@property (nonatomic) NSDate *date;
@property (nonatomic) NSString *name;
@property (nonatomic) NSDictionary *todoDict;
@property (nonatomic) NSURL *url;
@property (nonatomic) NSData *imageData;
@property (nonatomic) UIImage *image;

@property (nonatomic) id prop;
@property (nonatomic, getter=isCheck) BOOL check_bool;
@property (nonatomic) unsigned char ccheck;
@property (nonatomic) int inum;
@property (nonatomic) long lnum;

- (id)debugQuickLookObject;

@end
