//
//  HomeViewController.h
//  YesNo
//
//  Created by Ross Huelin on 13/03/2011.
//  Copyright 2011 Ross Huelin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AskingViewController.h"
#import "AnsweringViewController.h"

@class AskingViewController;
@class AnsweringViewController;

@interface HomeViewController : UIViewController {
	IBOutlet UIButton *ask;
	IBOutlet UIButton *answer;
	AskingViewController *askingViewController;
	AnsweringViewController *answeringViewController;	
}

@property(nonatomic, retain) IBOutlet AskingViewController *askingViewController;
@property(nonatomic, retain) IBOutlet AnsweringViewController *answeringViewController;

-(IBAction) asking:(id)sender;
-(IBAction) answering:(id)sender;

@end
