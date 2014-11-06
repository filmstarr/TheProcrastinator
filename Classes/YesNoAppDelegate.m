//
//  YesNoAppDelegate.m
//  YesNo
//
//  Created by Ross Huelin on 12/03/2011.
//  Copyright 2011 Ross Huelin. All rights reserved.
//

#import "YesNoAppDelegate.h"

@implementation YesNoAppDelegate

@synthesize window, navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
    [window addSubview:navigationController.view];
    [self.window makeKeyAndVisible];
	
	//Set some default values
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	[standardUserDefaults setObject:@"http://www.filmstarr.co.uk/Procrastinator/procrastinator.php" forKey:@"baseUrl"];
	[standardUserDefaults setInteger:40 forKey:@"batchSize"];
	
	//Check if we have a UDID
	BOOL udidIsSet = [standardUserDefaults boolForKey:@"udidIsSet"];
	if (udidIsSet == NO)
	{
		//Confirmation dialog	
		UIAlertView *alert = [[UIAlertView alloc] init];
		[alert setTitle:@"The Procrastinator"];
		[alert setMessage:@"We would like to store your device ID so we can remember who you are. Is this OK?"];
		[alert setDelegate:self];
		[alert addButtonWithTitle:@"Yes"];
		[alert addButtonWithTitle:@"No"];
		[alert show];
		[alert release];
	}
		
    return YES;
}

//Removing or deleting a question
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];

	//Can we use the users UDID?
	if (buttonIndex == 0)
	{
		//Check that we've got a proper UDID
		if ([[UIDevice currentDevice].uniqueIdentifier length] == 40) {
			[standardUserDefaults setObject:[UIDevice currentDevice].uniqueIdentifier forKey:@"udid"];
			[standardUserDefaults setBool:YES forKey:@"udidIsSet"];			
		}
		else {
			//Show the user a generic everyone else account
			[standardUserDefaults setObject:@"0000000000000000000000000000000000000000" forKey:@"udid"];
			[standardUserDefaults setBool:NO forKey:@"udidIsSet"];
			[self alert: @"Sorry, we could not retrieve a valid device ID. We'll show you the generic account for now."];
		}		
	}
	else {
		//Show the user a generic everyone else account
		[standardUserDefaults setObject:@"0000000000000000000000000000000000000000" forKey:@"udid"];			
		[standardUserDefaults setBool:NO forKey:@"udidIsSet"];			
	}
}

- (void)alert:(NSString *) alertString
{
	//show the user an error message
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"The Procrastinator" message:alertString delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
	[alertView show]; 
	[alertView release];
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [window release];
	[navigationController release];
    [super dealloc];
}


@end
