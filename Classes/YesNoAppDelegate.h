//
//  YesNoAppDelegate.h
//  YesNo
//
//  Created by Ross Huelin on 12/03/2011.
//  Copyright 2011 Ross Huelin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YesNoAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	UINavigationController *navController;
}

@property(nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

- (void)alert:(NSString *) alertString;

@end

