//
//  CocoaPropertyEnumerator.m
//  CocoaDebugKit
//
//  Created by Patrick Kladek on 25.04.16.
//  Copyright (c) 2016 Patrick Kladek. All rights reserved.
//

#import <objc/runtime.h>
#import "CocoaPropertyEnumerator.h"


@implementation CocoaPropertyEnumerator

static const char *getPropertyType(objc_property_t property)
{
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;

    /*
     *	Content of 'attribute'
     *
     T@"NSString",&,N,V_hallo
     T@"<TestObjectDelegate>",W,N,V_delegate
     T@"NSData",&,N,V_data
     T@"NSDate",&,N,V_date
     T@"NSImage",&,N,V_image
     T@,&,N,V_prop
     T@"NSSet",&,N,V_set
     T@"NSString",&,N,V_name
     T@"NSString",&,N,V_test
     Tc,N,GisCheck,V_check
     TC,N,V_ccheck
     Ti,N,V_inum
     Tq,N,V_lnum
     T@"NSURL",&,N,V_url
     T@"TestObject",&,N,V_object
     T@"NSString",&,N,V_hallo
     T@"<TestObjectDelegate>",W,N,V_delegate
     T@"NSData",&,N,V_data
     T@"NSDate",&,N,V_date
     T@"NSImage",&,N,V_image
     T@,&,N,V_prop
     T@"NSSet",&,N,V_set
     T@"NSString",&,N,V_name
     T@"NSString",&,N,V_test
     Tc,N,GisCheck,V_check
     TC,N,V_ccheck
     Ti,N,V_inum
     Tq,N,V_lnum
     T@"NSURL",&,N,V_url
     T@"TestObject",&,N,V_object
     */

    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            // it's a C primitive type:
            /*
             if you want a list of what will be returned for these primitives, search online for
             "objective-c" "Property Attribute Description Examples"
             apple docs list plenty of examples of what you get for int "i", long "l", unsigned "I", struct, etc.
             */

            switch (attribute[1]) {
                case 'c':
                    return "char";
                    break;
                case 'i':
                    return "int";
                    break;

                case 's':
                    return "short";
                    break;

                case 'l':
                    return "long";
                    break;

                case 'q':
                    return "long long";
                    break;

                case 'C':
                    return "unsigned char";
                    break;

                case 'I':
                    return "unsigned int";
                    break;

                case 'S':
                    return "unsigned short";
                    break;

                case 'L':
                    return "unsigned long";
                    break;

                case 'Q':
                    return "unsigned long long";
                    break;

                case 'f':
                    return "float";
                    break;

                case 'd':
                    return "double";
                    break;

                case 'B':
                    return "bool";
                    break;

                case 'v':
                    return "void";
                    break;

                case '*':
                    return "char *";
                    break;

                default:
                    break;
            }

            return (const char *) [[NSData dataWithBytes:(attribute + 1) length:strlen(attribute) - 1] bytes];
        } else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            // it's an ObjC id type:
            return "id";
        } else if (attribute[0] == 'T' && attribute[1] == '@') {
            // it's another ObjC object type:
            return (const char *) [[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
        }
    }
    return "";
}

- (void)enumeratePropertiesFromClass:(Class)objectClass allowed:(NSArray *)allowed block:(void (^)(NSString *type, NSString *value))callbackBlock
{
    // get all properties and Display them in DebugView ...
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(objectClass, &outCount);

    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);

        if (propName) {
            const char *type = getPropertyType(property);
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            NSString *propertyType = [NSString stringWithUTF8String:type];

            if (allowed && [self object:propertyName existsInArray:allowed]) {
                callbackBlock(propertyType, propertyName);
            } else {
                callbackBlock(propertyType, propertyName);
            }
        }
    }
    free(properties);
}

- (NSString *)propertyTypeFromName:(NSString *)name object:(NSObject *)obj
{
    // get all properties and Display them in DebugView ...
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([obj class], &outCount);

    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);

        if (propName) {
            const char *type = getPropertyType(property);
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            NSString *propertyType = [NSString stringWithUTF8String:type];

            if ([propertyName isEqualToString:name]) {
                free(properties);
                return propertyType;
            }
        }
    }
    free(properties);
    return nil;
}

- (BOOL)object:(NSString *)object existsInArray:(NSArray *)array
{
    for (NSString *property in array) {
        if ([property isEqualToString:object]) {
            return true;
        }
    }

    return false;
}

@end
