//
//  AnsweringViewController.h
//  YesNo
//
//  Created by Ross Huelin on 13/03/2011.
//  Copyright 2011 Ross Huelin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionTableViewController.h"

@interface AnsweringViewController : QuestionTableViewController {
	NSMutableData *questionData;
}

- (void)submissionFailed;

@end
