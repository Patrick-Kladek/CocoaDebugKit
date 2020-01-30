//
//  ViewController.m
//  TestApp
//
//  Created by Patrick Kladek on 22.05.17.
//  Copyright (c) 2017 Patrick Kladek. All rights reserved.
//

#import <CocoaDebugKit/CocoaDebugKit.h>
#import "TestClass.h"
#import "ViewController.h"


@interface ViewController ()

@end


@implementation ViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	CocoaDebugView *view = [CocoaDebugView debugView];
	[view addLineWithDescription:@"Custom" boolean:YES];
	[view addLineWithDescription:@"test" string:@"Hello World"];
	[view addLineWithDescription:@"Long Text" string:@"Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam"];
	
	view.frame = CGRectMake(50, 20, view.frame.size.width, view.frame.size.height);
	[self.view addSubview:view];

	TestClass *test = [TestClass new];
	NSLog(@"%@", [test debugDescription]);

    UIImageView *view1 = [[UIImageView alloc] initWithImage:[test debugQuickLookObject]];
	view1.frame = CGRectMake(10, 150, view1.frame.size.width, view1.frame.size.height);
	[self.view addSubview:view1];
}

@end
