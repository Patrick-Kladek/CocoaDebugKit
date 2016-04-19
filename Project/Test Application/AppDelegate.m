//
//  AppDelegate.m
//  Test Application
//
//  Created by Patrick Kladek on 21.05.15.
//  Copyright (c) 2015 Patrick Kladek. All rights reserved.
//

#import "AppDelegate.h"
#import <pkDebugFramework/pkDebugFramework.h>
#import "pkTestObject.h"
#import "Person.h"

@interface AppDelegate () <pkTestObjectDelegate>

@property (weak) IBOutlet NSWindow *window;
@end



@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	
	// init debugFramework
	NSURL *url = [[NSBundle mainBundle] URLForResource:@"com.kladek.pkDebugFramework.settings.default" withExtension:@"plist"];
	[[pkDebugSettings sharedSettings] loadSettings:url];
	
	
	pkDebugView *view = [pkDebugView debugView];
	[view setTitle:@"ClassName"];
	[view setFrameColor:[NSColor purpleColor]];
	
	
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
	
	
	// ------------------------------------------------------------------------
	pkTestObject *obj = [[pkTestObject alloc] init];
	[obj setDelegate:self];
	[obj setDate:[NSDate date]];
	
	NSImage *image = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image" ofType:@"png"]];
	[obj setData:[image TIFFRepresentation]];
	
	
	[obj setSet:[NSSet setWithObject:@"Hallo"]];
	[obj setImage:image];
	[obj setTest:@"Hallo World"];
	[obj setName:@"Name yxcvb"];
	[obj setCheck:YES];
	[obj setInum:32000];
	[obj setLnum:64000];
	[obj setCcheck:'r'];
	[obj setUrl:[NSURL URLWithString:@"file:///Users/patrick/Desktop/"]];
	
	pkTestObject *obj2 = [[pkTestObject alloc] init];
	[obj2 setName:@"hugo"];
	[obj setObject:obj2];
	
	
	NSView *newView = [obj debugQuickLookObject];
	[newView setFrame:NSOffsetRect(newView.frame, 600, 50)];
	[[[self window] contentView] addSubview:newView];
	
	
	
	Person *person = [[Person alloc] init];
	[person setImage:[NSImage imageNamed:NSImageNameUser]];
	[person setFirstName:@"Mark"];
	[person setLastName:@"Johnson"];
	[person setBirthday:[NSDate dateWithTimeIntervalSince1970:5*365*60*600]];
	NSLog(@"%@", person);
	
	[[[self window] contentView] addSubview:[person debugQuickLookObject]];
}

- (void)smt
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
