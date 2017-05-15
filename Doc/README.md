# CocoaDebugKit
<img src="https://github.com/Patrick-Kladek/pkDebugFramework/blob/master/Doc/Build%20Badge.png" height="25">
<img src="https://github.com/Patrick-Kladek/pkDebugFramework/blob/master/Doc/Compatibility%20Badge.png" height="25">
<img src="https://github.com/Patrick-Kladek/pkDebugFramework/blob/master/Doc/Tested%20Badge.png" height="25">

Tools for debugging with Xcode


This project helps developers to visualize custom objects and will therefore speed up your development process.

Lets say we have a custom Object called "Person" and want to inspect all variables in Xcode. This will look something like that:

![alt text](https://github.com/Patrick-Kladek/pkDebugFramework/blob/master/Doc/old%20Debug.png "Logo Title Text 1")

With this framework it can look like this:

![alt text](https://github.com/Patrick-Kladek/pkDebugFramework/blob/master/Doc/new%20Debug.png "Logo Title Text 1")


So how can we achieve this goal? It´s easy just add this Framework to your Project and implement this method in your custom object:

```objective-c
#import "Person.h"
#import <CocoaDebugKit/CocoaDebugKit.h>


@implementation Person

- (id)debugQuickLookObject
{
	CocoaDebugView *view = [CocoaDebugView debugViewWithAllPropertiesOfObject:self includeSuperclasses:YES];
	
	return view;
}

@end
```

After that set a breakpoint in your code, select an object you want to inspect and hit space. This will open a small quicklook popover with the contents of your object.