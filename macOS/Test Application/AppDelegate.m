//
//  AppDelegate.m
//  Test Application
//
//  Created by Patrick Kladek on 21.05.15.
//  Copyright (c) 2015 Patrick Kladek. All rights reserved.
//

#import <CocoaDebugKit/CocoaDebugKit.h>
#import "AppDelegate.h"
#import "Person.h"
#import "SecondObject.h"
#import "TestObject.h"

@interface AppDelegate () <TestObjectDelegate>

@property (weak) IBOutlet NSWindow *window;

@end


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // init debugFramework
    // Note: if sharedInstance is not initialized default values are used.
    // Note: in this example every debugView is saved to ~/Desktop/debugView. You can turn this off by setting the key: debugView.appearance.key in plist to false.
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"com.kladek.CocoaDebugKit.settings.default" withExtension:@"plist"];
    [[CocoaDebugSettings sharedSettings] loadSettings:url];

    [self createStaticDebugView];
    [self createDynamicDebugView];
    [self createDynamicDebugViewPerson];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

// MARK: - DebugViews

- (void)createStaticDebugView
{
    CocoaDebugView *view = [CocoaDebugView debugView];
    [view setTitle:@"ClassName"];
    [view setFrameColor:[NSColor purpleColor]];

    [view addLineWithDescription:@"Name:" string:@"Value"];
    [view addLineWithDescription:@"Name:" string:@"Value12315645"];
    [view addLineWithDescription:@"Name:" string:@"Value"];
    [view addLineWithDescription:@"NameHalloskfajds:" string:@"Value"];
    [view addLineWithDescription:@"NameHalloskfajds:" integer:12384];
    [view addLineWithDescription:@"dfg:" floating:456462.56451354615135468];


    NSArray *array = @[
        @"file:///Users/patrick/Desktop/myAwesomeProject1/",
        @"file:///Users/patrick/Desktop/myAwesomeProject2/",
        @"file:///Users/patrick/Desktop/myAwesomeProject3/"
    ];
    [view addLineWithDescription:@"array" string:array.description];

    [view addLineWithDescription:@"test" string:nil];
    [view addLineWithDescription:@"test" boolean:YES];
    [view addLineWithDescription:@"test" boolean:NO];

    [view setFrame:NSOffsetRect(view.frame, 460, 20)];
    [[[self window] contentView] addSubview:view];
}

- (void)createDynamicDebugView
{
    SecondObject *obj = [[SecondObject alloc] init];
    [obj setDelegate:self];
    [obj setDate:[NSDate date]];

    NSImage *image = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image" ofType:@"jpg"]];
    [obj setDataImage:[image TIFFRepresentation]];

    [obj setHallo:@"Hello World"];
    [obj setSet:[NSSet setWithObject:@"Hallo"]];
    [obj setImage:image];
    [obj setTest:@"Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.\nDuis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat.\nUt wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi.\nNam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat.\nDuis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis.\nAt vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, At accusam aliquyam diam diam dolore dolores duo eirmod eos erat, et nonumy sed tempor et et invidunt justo labore Stet clita ea et gubergren, kasd magna no rebum. sanctus sea sed takimata ut vero voluptua. est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur"];
    [obj setName:@"Name yxcvb"];
    [obj setCheck_bool:YES];
    [obj setInum:32000];
    [obj setLnum:64000];
    [obj setCcheck:'r'];
    [obj setUrl:[NSURL URLWithString:@"file:///Users/patrick/Desktop/"]];
    [obj setColor:[NSColor colorWithCalibratedRed:0.461 green:1.000 blue:0.962 alpha:0.540]];
    [obj setError:[NSError errorWithDomain:@"com.kladek.CocoaDebugKit" code:5645 userInfo:@{
        NSLocalizedFailureReasonErrorKey: @"LocalizedFailureReason",
        NSLocalizedDescriptionKey: @"Something went wrong",
        NSLocalizedRecoverySuggestionErrorKey: @"LocalizedRecoverySuggestion, do some thing, need some text for testing, do something more to reproduce this error",
        NSLocalizedRecoveryOptionsErrorKey: @"LocalizedRecoveryOptions",
        NSRecoveryAttempterErrorKey: @"RecoveryAttempter",
        NSHelpAnchorErrorKey: @"HelpAnchor",
        NSStringEncodingErrorKey: @"NSStringEncodingError",
        NSURLErrorKey: @"NSURLError",
        NSFilePathErrorKey: @" NSFilePathError"
    }]];
    TestObject *obj2 = [[TestObject alloc] init];
    [obj setObject:obj2];

    NSView *newView = [obj debugQuickLookObject];
    [newView setFrame:NSOffsetRect(newView.frame, 20, 20)];
    [[[self window] contentView] addSubview:newView];
}

- (void)createDynamicDebugViewPerson
{
    Person *person = [[Person alloc] init];
    [person setImage:[NSImage imageNamed:@"image.jpg"]];
    [person setFirstName:@"Patrick"];
    [person setLastName:@"Kladek"];
    [person setBirthday:[NSDate dateWithString:@"1996-07-04 01:00:00 +0100"]];

    NSView *view2 = [person debugQuickLookObject];
    [view2 setFrame:NSOffsetRect(view2.frame, 460, 385)];

    [[[self window] contentView] addSubview:view2];
    NSLog(@"%@", [person debugDescription]);
}

/**
 *	CocoaTestObjectDelegate
 */
- (void)smt
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
