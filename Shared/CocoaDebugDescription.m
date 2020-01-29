//
//  CocoaDebugDescription.m
//  CocoaDebugKit
//
//  Created by Patrick Kladek on 19.04.16.
//  Copyright (c) 2016 Patrick Kladek. All rights reserved.
//

#import "CocoaDebugDescription.h"
#import "CocoaPropertyEnumerator.h"
#import "CocoaDebugSettings.h"
#import "NSObject+CPAdditions.h"


@interface CocoaDebugDescription ()

@property (nonatomic) CocoaPropertyEnumerator *propertyEnumerator;
@property (nonatomic) NSMutableArray *lines;
@property (nonatomic) NSInteger typeLenght;

@end


@implementation CocoaDebugDescription

+ (CocoaDebugDescription *)debugDescription
{
    CocoaDebugDescription *description = [[self alloc] init];
    return description;
}

+ (CocoaDebugDescription *)debugDescriptionForObject:(NSObject *)obj
{
    CocoaDebugDescription *description = [[self alloc] init];
    [description addAllPropertiesFromObject:obj];
    return description;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyEnumerator = [[CocoaPropertyEnumerator alloc] init];
        _lines = [NSMutableArray array];
        _typeLenght = 0;

        CocoaDebugSettings *settings = [CocoaDebugSettings sharedSettings];

        self.dataMaxLenght = settings.maxDataLenght;
        self.save = settings.save;
        self.saveUrl = settings.saveUrl;
    }
    return self;
}

- (void)addAllPropertiesFromObject:(NSObject *)obj
{
    _obj = obj;

    Class currentClass = [obj class];

    while (currentClass != nil && currentClass != [NSObject class]) {
        [self.propertyEnumerator enumeratePropertiesFromClass:currentClass
                                                      allowed:nil
                                                        block:^(NSString *type, NSString *name) {
            [self addProperty:name type:type fromObject:obj];
        }];

        currentClass = [currentClass superclass];
    }
}

- (void)addProperty:(NSString *)name type:(NSString *)type fromObject:(NSObject *)obj
{
    if (!_obj) {
        _obj = obj;
    }


    Class class = NSClassFromString(type);

    if ([class isSubclassOfClass:[NSData class]]) {
        NSData *data = [obj valueForKey:name];

        // cut lenght to 100 byte
        if ([data length] > self.dataMaxLenght.integerValue) {
            data = [data subdataWithRange:NSMakeRange(0, self.dataMaxLenght.integerValue)];
        }

        [self addDescriptionLine:[CocoaPropertyLine lineWithType:type name:name value:[data description]]];
        return;
    }

    if ([class isSubclassOfClass:[CPImage class]]) {
        CPImage *image = [obj valueForKey:name];
        NSString *imageDescription = [NSString stringWithFormat:@"size: %.0fx%.0f", image.size.width, image.size.height];
        [self addDescriptionLine:[CocoaPropertyLine lineWithType:type name:name value:imageDescription]];
        return;
    }


    id value = [obj valueForKey:name];
    NSString *description = [[value description] stringByReplacingOccurrencesOfString:@"\n" withString:[NSString stringWithFormat:@"\n%@", [self _spaceFromLenght:4]]];
    [self addDescriptionLine:[CocoaPropertyLine lineWithType:type name:name value:description]];
}

- (NSString *)stringRepresentation
{
    NSMutableString *string = [NSMutableString stringWithFormat:@"<%p> %@ {\n", _obj, _obj.cp_className];
    for (CocoaPropertyLine *line in self.lines) {
        NSInteger deltaLenght = self.typeLenght - (line.type.length + line.name.length);
        [string appendFormat:@"\t%@%@ %@ = %@\n", line.type, [self _spaceFromLenght:deltaLenght], line.name, line.value];
    }

    [string appendString:@"}"];
    return string;
}

- (void)saveDebugDescription
{
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];// example: 1.0.0
    NSString *buildNumber = [infoDict objectForKey:@"CFBundleVersion"];// example: 42

    NSURL *url = [_saveUrl URLByAppendingPathComponent:appVersion];
    url = [url URLByAppendingPathComponent:buildNumber];

    NSError *error;
    if (![[NSFileManager defaultManager] createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&error]) {
        NSLog(@"%@", error);
        return;
    }

    NSString *className = [_obj cp_className];

    NSDictionary *debuggedObjects = [[CocoaDebugSettings sharedSettings] debuggedObjects];
    NSInteger debuggedCount = [[debuggedObjects valueForKey:className] integerValue];
    debuggedCount++;
    [debuggedObjects setValue:[NSNumber numberWithInteger:debuggedCount] forKey:className];
    url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@ %li.txt", className, (long) debuggedCount]];

    [self saveDebugDescriptionToUrl:url error:nil];
}

- (BOOL)saveDebugDescriptionToUrl:(NSURL *)url error:(NSError **)error
{
    return [[self stringRepresentation] writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:error];
}

#pragma mark - Private

- (NSString *)_spaceFromLenght:(NSInteger)lenght
{
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:lenght];
    for (NSInteger i = 0; i < lenght; i++) {
        [string appendString:@" "];
    }
    return string;
}

- (void)addDescriptionLine:(CocoaPropertyLine *)line
{
    if (line.type.length + line.name.length > self.typeLenght) {
        self.typeLenght = line.type.length + line.name.length;
    }

    [self.lines addObject:line];
}

@end
