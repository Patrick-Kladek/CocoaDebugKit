//
//  pkDebugDescription.h
//  pkDebugFramework
//
//  Created by Patrick Kladek on 19.04.16.
//  Copyright (c) 2016 Patrick Kladek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface pkDebugDescription : NSObject


@property (nonatomic) NSNumber *dataMaxLenght;



- (void)addAllPropertiesFromObject:(NSObject *)obj;

- (NSString *)descriptionForObject:(NSObject *)object;

@end
