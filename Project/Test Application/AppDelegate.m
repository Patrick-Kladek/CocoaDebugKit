//
//  AppDelegate.m
//  Test Application
//
//  Created by Patrick Kladek on 21.05.15.
//  Copyright (c) 2015 Patrick Kladek. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	
	pkDebugView *view = [pkDebugView debugView];
	[view setTitle:@"ClassName"];
	[view setColor:[NSColor purpleColor]];
	
	
	[view addLineWithDescription:@"Name:"				string:@"Value"];
	[view addLineWithDescription:@"Name:"				string:@"Value12315645"];
	[view addLineWithDescription:@"Name:"				string:@"Value"];
	[view addLineWithDescription:@"NameHalloskfajds:"	string:@"Value"];
	[view addLineWithDescription:@"NameHalloskfajds:"	integer:12384];
	[view addLineWithDescription:@"dfg:"				floating:456462.56451354615135468];
	
	
	NSArray *array = [NSArray arrayWithObjects:
					  @"file:///Users/patrick/Desktop/myAwesomeProject/",
					  @"file:///Users/patrick/Desktop/myAwesomeProject/",
					  @"file:///Users/patrick/Desktop/myAwesomeProject/", nil];
	[view addLineWithDescription:@"array" string:array.description];
	
	
	[view addLineWithDescription:@"test" string:nil];
	[view addLineWithDescription:@"test" boolean:YES];
	[view addLineWithDescription:@"test" boolean:NO];
	
	
	[view setFrame:NSOffsetRect(view.frame, 50, 50)];
	[[[self window] contentView] addSubview:view];
}

@end
