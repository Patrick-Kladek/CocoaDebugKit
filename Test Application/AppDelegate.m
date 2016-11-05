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
#import "pkSecondObject.h"

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
	
	[self createStaticDebugView];
	
	[self createDynamicDebugView];
	
	[self createDynamicDebugViewPerson];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}



// -----------------------------
#pragma mark - DebugViews

- (void)createStaticDebugView
{
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
	
	
	[view setFrame:NSOffsetRect(view.frame, 20, 212)];
	[[[self window] contentView] addSubview:view];
}

- (void)createDynamicDebugView
{
	pkSecondObject *obj = [[pkSecondObject alloc] init];
	[obj setDelegate:self];
	[obj setDate:[NSDate date]];
	
	NSImage *image = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image" ofType:@"png"]];
	[obj setDataImage:[image TIFFRepresentation]];
	
	
	[obj setSet:[NSSet setWithObject:@"Hallo"]];
	[obj setImage:image];
	[obj setTest:@"Hallo World"];
	[obj setName:@"Name yxcvb"];
	[obj setCheck_bool:YES];
	[obj setInum:32000];
	[obj setLnum:64000];
	[obj setCcheck:'r'];
	[obj setUrl:[NSURL URLWithString:@"file:///Users/patrick/Desktop/"]];
	[obj setColor:[NSColor colorWithCalibratedRed:0.461 green:1.000 blue:0.962 alpha:0.540]];
	[obj setError:[NSError errorWithDomain:@"com.kladek.pkDebugFramework" code:5645 userInfo:@{ NSLocalizedFailureReasonErrorKey:@"LocalizedFailureReason",
																								NSLocalizedDescriptionKey:@"Something went wrong",
																								NSLocalizedRecoverySuggestionErrorKey:@"LocalizedRecoverySuggestion, do some thing, need some text for testing, do something more to reproduce this error",
																								NSLocalizedRecoveryOptionsErrorKey:@"LocalizedRecoveryOptions",
																								NSRecoveryAttempterErrorKey:@"RecoveryAttempter",
																								NSHelpAnchorErrorKey:@"HelpAnchor",
																								NSStringEncodingErrorKey:@"NSStringEncodingError",
																								NSURLErrorKey:@"NSURLError",
																								NSFilePathErrorKey:@" NSFilePathError"
																								}]];
	pkTestObject *obj2 = [[pkTestObject alloc] init];
	[obj2 setName:@"hugo"];
	[obj setObject:obj2];
	
	
	NSView *newView = [obj debugQuickLookObject];
	[newView setFrame:NSOffsetRect(newView.frame, 602, 39)];
	[[[self window] contentView] addSubview:newView];
}

- (void)createDynamicDebugViewPerson
{
	Person *person = [[Person alloc] init];
	[person setImage:[NSImage imageNamed:NSImageNameUser]];
	[person setFirstName:@"Mark"];
	[person setLastName:@"Johnson"];
	[person setBirthday:[NSDate date]];
	
	NSView *view2 = [person debugQuickLookObject];
	[view2 setFrame:NSOffsetRect(view2.frame, 20, 20)];
	
	[[[self window] contentView] addSubview:view2];
	
	
	pkDebugDescription *desc = [[pkDebugDescription alloc] init];
	NSString *str = [desc descriptionForObject:person];
	NSLog(@"%@", str);
}


/**
 *	pkTestObjectDelegate
 */
-(void)smt
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
}


@end
