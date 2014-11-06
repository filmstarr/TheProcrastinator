    //
//  AskingViewController.m
//  YesNo
//
//  Created by Ross Huelin on 12/03/2011.
//  Copyright 2011 Ross Huelin. All rights reserved.
//

#import "AskingViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation AskingViewController

@synthesize questionText;

#pragma mark UIViewController delegate methods

- (void)viewDidLoad {
	//Round off corners
	questionText.layer.cornerRadius = 10;
	questionText.clipsToBounds = YES;
	
	//Initialise view
	submittingQuestion = NO;
	defaultQuestionText = @"Please enter your YES/NO question here...";
	[self resetQuestionText];
	action = @"retrieve_questions";
	answerSitchEnabled = NO;
	myQuestions = YES;
  
	//Set title
	self.title = @"Questions";
	
	[super viewDidLoad];	
}

- (void)dealloc {
	[questionText release];
    [super dealloc];
}

#pragma mark -
#pragma mark Question Loading

-(void)resetView {	
	if (submittingQuestion) {
		[self performSelectorOnMainThread:@selector(resetQuestionText) withObject:nil waitUntilDone:NO];
	}
	submittingQuestion = NO;
	[super resetView];
}

-(void)operationFailed {
	if (submittingQuestion)
	{
		[self performSelectorOnMainThread:@selector(alert:) withObject:@"Sorry, question submission failed. Note: You may not submit duplicate questions within 24hrs." waitUntilDone:NO];
	}
	else {
		[self performSelectorOnMainThread:@selector(alert:) withObject:@"Sorry, question retrieval failed. Please try again." waitUntilDone:NO];
	}	
  [super operationFailed];
}

#pragma mark -
#pragma mark Question Submission Methods

-(IBAction)submitQuestion:(id) sender {
	NSLog(@"Submitting Question");
	
	//Get and format the question text
	NSString *formattedQuestionText = [[[[[[questionText text]
										  stringByReplacingOccurrencesOfString:@"\n" withString:@" "]
										 stringByReplacingOccurrencesOfString:@"\t" withString:@" "]
										 stringByReplacingOccurrencesOfString:@"%" withString:@"%%"]
										 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
										 stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];	

	if ([[formattedQuestionText stringByReplacingOccurrencesOfString:@"?" withString:@""] length] != 0 && ![[questionText text] isEqualToString:defaultQuestionText]){
		submittingQuestion = YES;
		reloading = YES;
		self.questionList = [[NSMutableArray alloc] initWithObjects:nil];
		lastQuestionId = -1;
		firstUserQuestion = -1;
		[self showLoadingView];

		//Submit a question then load users questions
		NSString *strQuestionsUrl = [NSString stringWithFormat:@"%@?action=submit_question_retrieve_questions&udid=%@&question=%@",baseUrl, udid, formattedQuestionText];
		strQuestionsUrl = [NSString stringWithFormat:@"%@&batch_size=%d",strQuestionsUrl, batchSize*2];
		NSURL* urlQuestion = [NSURL URLWithString:strQuestionsUrl];		
		[self performLoad:urlQuestion];
	}
	else {
		[self alert: @"Please enter a valid question."];
	}
		
	[questionText resignFirstResponder];
}

- (void)resetQuestionText {
	questionText.text = defaultQuestionText;
	questionText.textColor = [UIColor colorWithRed:0.65 green:0.65 blue:0.65 alpha:1.0];

	questionText.selectedRange = NSMakeRange(0, 0);	
}

#pragma mark -
#pragma mark UITextView Methods

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range  replacementText:(NSString *)text
{
	if ([text isEqualToString:@"\n"]) {
		[textView resignFirstResponder];
		return NO;
	}
	
	return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
	if ([textView.text isEqualToString:defaultQuestionText]) {
		textView.text = @"";
		questionText.textColor = [UIColor colorWithRed:0.098 green:0.098 blue:0.098 alpha:1.0];
	}
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	if ([textView.text isEqualToString:@""]) {
		textView.text = defaultQuestionText;
		questionText.textColor = [UIColor colorWithRed:0.65 green:0.65 blue:0.65 alpha:1.0];
	}
}

#pragma mark -

@end
