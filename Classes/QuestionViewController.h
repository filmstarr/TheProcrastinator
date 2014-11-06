//
//  QuestionViewController.h
//  YesNo
//
//  Created by Ross Huelin on 05/05/2011.
//  Copyright 2011 Ross Huelin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingView.h"
#import "UICustomSwitch.h"
#import "PieChart.h"


@interface QuestionViewController : UIViewController {
	IBOutlet UITextView *questionText;
	NSMutableArray *questionDetails;
	IBOutlet UIView *contentView;
	BOOL loadingViewShowing;
	NSString *baseUrl;
	NSString *udid;
	LoadingView *loadingView;
	LoadingView *smallLoadingView;
	NSInteger row;
	UIBackgroundTaskIdentifier backgroundTask;
	BOOL myQuestion;
	IBOutlet UISegmentedControl *answerControl;
	BOOL loaded;
	NSMutableData *questionData;
	BOOL submittingAnswer;
	IBOutlet PieChart *myPie;
}

@property(nonatomic, retain) UITextView *questionText;
@property(nonatomic, retain) NSMutableArray *questionDetails;
@property(nonatomic, retain) UIView *contentView;
@property(nonatomic, retain) UISegmentedControl *answerControl;
@property(nonatomic, retain) PieChart *myPie;
@property(nonatomic, assign) NSInteger row;
@property(nonatomic, assign) BOOL myQuestion;

-(void)reload;
-(void)setQuestionValues;
-(IBAction)answerQuestion:(id)sender;
- (void)showLoadingView;
- (void)hideLoadingView;
- (void)submissionFailed;
- (void)processQuestion: (NSString *) question;

@end
