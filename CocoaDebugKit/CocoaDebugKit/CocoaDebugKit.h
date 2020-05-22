//
//  CocoaDebugKit.h
//  CocoaDebugKit
//
//  Created by Patrick Kladek on 21.05.15.
//  Copyright (c) 2015 Patrick Kladek. All rights reserved.
//

#include <TargetConditionals.h>

#if TARGET_OS_IPHONE
    @import UIKit;
#else
    @import AppKit;
#endif


//! Project version number for CocoaDebugKit.
FOUNDATION_EXPORT double CocoaDebugFrameworkVersionNumber;

//! Project version string for CocoaDebugKit.
FOUNDATION_EXPORT const unsigned char CocoaDebugFrameworkVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <CocoaDebugKit/PublicHeader.h>


#import <CocoaDebugKit/CocoaDebugView.h>
#import <CocoaDebugKit/CocoaDebugSettings.h>
#import <CocoaDebugKit/CocoaDebugDescription.h>
#import <CocoaDebugKit/CocoaPropertyEnumerator.h>
#import <CocoaDebugKit/CrossPlatformDefinitions.h>


//#import "CocoaDebugView.h"
//#import "CocoaDebugSettings.h"
//#import "CocoaDebugDescription.h"
//#import "CocoaPropertyEnumerator.h"

