//
//  AskingViewController.h
//  YesNo
//
//  Created by Ross Huelin on 12/03/2011.
//  Copyright 2011 Ross Huelin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionTableViewController.h"

@interface AskingViewController : QuestionTableViewController {
	IBOutlet UITextView *questionText;
	BOOL submittingQuestion;
	NSString *defaultQuestionText;
}

@property(nonatomic,retain) UITextView *questionText;

-(IBAction) submitQuestion:(id)sender;
- (void)resetQuestionText;

@end
