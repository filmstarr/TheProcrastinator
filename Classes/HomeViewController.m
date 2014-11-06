//
//  HomeViewController.m
//  YesNo
//
//  Created by Ross Huelin on 13/03/2011.
//  Copyright 2011 Ross Huelin. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeViewController.h"
#import "AskingViewController.h"
#import "AnsweringViewController.h"


@implementation HomeViewController

@synthesize askingViewController, answeringViewController;

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
	[askingViewController release];
	[answeringViewController release];
    [super dealloc];
}


#pragma mark -
#pragma mark User interface actions

-(IBAction)asking:(id) sender
{
	NSLog(@"Asking");
	UIViewController *avc = [[AskingViewController alloc] initWithNibName:@"Asking" bundle:nil];
	[self.navigationController pushViewController:avc animated:YES];	
	[avc release];
}

-(IBAction)answering:(id) sender
{
	NSLog(@"Answering");
	UIViewController *avc = [[AnsweringViewController alloc] initWithNibName:@"Answering" bundle:nil];
	[self.navigationController pushViewController:avc animated:YES];	
	[avc release];
}


@end
