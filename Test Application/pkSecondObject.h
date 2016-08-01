//
//  pkSecondObject.h
//  pkDebugFramework
//
//  Created by Patrick Kladek on 25.04.16.
//  Copyright (c) 2016 Patrick Kladek. All rights reserved.
//

#import "pkTestObject.h"

@interface pkSecondObject : pkTestObject

@property (nonatomic) NSString *hallo;
@property (nonatomic) NSColor *color;
@property (nonatomic) NSError *error;

@end
