CocoaDebugKit
============
[![Twitter: @PatrickKladek](https://img.shields.io/badge/twitter-@PatrickKladek-orange.svg?style=flat)](https://twitter.com/PatrickKladek)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/Patrick-Kladek/CocoaDebugKit/blob/master/LICENSE.md)
![Build](https://img.shields.io/badge/build-Xcode%2011-blue.svg)
![Platform](https://img.shields.io/badge/platform-macOS%2010.9+%20|%20iOS%208.0+-blue.svg)
![Tested](https://img.shields.io/badge/tested-macOS%2010.9%20|%20iOS%208.0-blue.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)


Debugging made easy. Automatically create QuickLook images of custom objects.


This project helps developers to visualize custom objects and will therefore speed up your development process.

Lets say we have a custom Object called "Person" and want to inspect all variables in Xcode. This will look something like that:

![alt text](https://raw.githubusercontent.com/Patrick-Kladek/CocoaDebugKit/master/Doc/old%20Debug.png "Classic Debug View")

With CocoaDebugKit it will look like this:

![alt text](https://raw.githubusercontent.com/Patrick-Kladek/CocoaDebugKit/master/Doc/new%20Debug.png "Debug View with custom rendered QuickLook image")


So how can we achieve this goal? It´s easy just add this Framework to your Project and implement this method in your custom object:

```objective-c
#import "Person.h"
#import <CocoaDebugKit/CocoaDebugKit.h>


@implementation Person

- (id)debugQuickLookObject
{
    return [CocoaDebugView debugViewWithAllPropertiesOfObject:self includeSuperclasses:YES];
}

@end
```

After that set a breakpoint in your code, select an object you want to inspect and hit space. This will open a small quicklook popover with the contents of your object.



## Requirements
- macOS 10.9+
- iOS 8+
- Xcode 11+

## Installation

The prefered way to use CocoaDebugKit is via Carthage. Simply add this line to your cartfile:

```
github "Patrick-Kladek/CocoaDebugKit"
```

and run:

```
carthage update --platform ios
```

## Known Limitations
- NSObject rootclass required
- Cocoa Runtime

Both of these limitations don't prevent you from using CocoaDebugKit. You can always create the debugView manually:

```objective-c
- (id)debugQuickLookObject
{
    CocoaDebugView *view = [CocoaDebugView debugView];

    [view addLineWithDescription:@"Image:" image:self.image];
    [view addLineWithDescription:@"First Name:" string:self.firstName];
    [view addLineWithDescription:@"Last Name:" string:self.lastName];
    [view addLineWithDescription:@"Birthday" date:self.birthday];

    return view;
}

```

## Note
On iOS returning a UIView subclass to QuickLook may result in an empty preview. To fix this simply return an image.

```objecitve-c
return [[CocoaDebugView debugViewWithAllPropertiesOfObject:self includeSuperclasses:YES] imageRepresentation];
```
