    //
//  AnsweringViewController.m
//  YesNo
//
//  Created by Ross Huelin on 13/03/2011.
//  Copyright 2011 Ross Huelin. All rights reserved.
//

#import "AnsweringViewController.h"

@implementation AnsweringViewController

#pragma mark UIViewController delegate methods

- (void)viewDidLoad {
	//Set title
	self.title = @"Answers";

	//Initialise view
	action = @"retrieve_answers";
	answerSitchEnabled = YES;
	myQuestions = NO;

	[super viewDidLoad];
}

#pragma mark -
#pragma mark Asynchronous request actions

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    questionData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [questionData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"Error: %@", error);
    [questionData release];
    [connection release];
	[self submissionFailed];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{	
	//Get a result of answer submission
	NSString *result = [[[NSString alloc] initWithData:questionData encoding: NSASCIIStringEncoding] autorelease];
	
	//Check for failure
	if ([result isEqual: @"0"]) {
		[self submissionFailed];
	}
    [questionData release];
}

- (void)submissionFailed {
	[self alert: @"Sorry, answer submission failed. Reloading answers."];
	reloading = YES;
	[self loadQuestions];
}

#pragma mark -
#pragma mark Question Loading

-(void)operationFailed {
	[self performSelectorOnMainThread:@selector(alert:) withObject:@"Sorry, we could not load your answers. Please try again." waitUntilDone:NO];
	[super operationFailed];
}

#pragma mark -
#pragma mark Question Answering Methods

- (void)answerQuestion:(id)sender{	
	//Get values
	UISwitch *answerSwitch = (UISwitch *)sender;
	UITableViewCell *cell = (UITableViewCell *)answerSwitch.superview;
	UITableView *tableView = (UITableView *)cell.superview;
	NSIndexPath *indexPath = [tableView indexPathForCell:cell];
	NSString *questionId = [[self.questionList objectAtIndex:[indexPath row]] objectAtIndex:0];
	NSString *answerString = @"2";
	
	//Generate our answer string
	if (answerSwitch.on) {
		answerString = @"1";
	}
	else {
		answerString = @"0";
	}

	NSUInteger row = [indexPath row];
	NSString *previousAnswer = [[[questionList objectAtIndex:row] objectAtIndex:2] copy];
	
	//Re set the value in our array
	[[self.questionList objectAtIndex:row] replaceObjectAtIndex:2 withObject: answerString];

	//Re set the totals
	NSString *totalYesCountStr = [[[self.questionList objectAtIndex:[indexPath row]] objectAtIndex:3] copy];
	NSString *totalAnswerCountStr = [[[self.questionList objectAtIndex:[indexPath row]] objectAtIndex:4] copy];
	int totalYesCount = 0;
	int totalAnswerCount = 0;
	
	NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
	if ([f numberFromString: totalYesCountStr] && [f numberFromString: totalAnswerCountStr])	{
		totalYesCount = [totalYesCountStr intValue];
		totalAnswerCount = [totalAnswerCountStr intValue];
	}
	[f release];
	
	if ([previousAnswer isEqualToString: @"2"]) {
		totalAnswerCount += 1;
	}
	if (![previousAnswer isEqualToString: @"1"] && [answerString isEqualToString: @"1"]) {
		totalYesCount += 1;
	}
	if ([previousAnswer isEqualToString: @"1"] && [answerString isEqualToString: @"0"]) {
		totalYesCount -= 1;
	}
	[[self.questionList objectAtIndex:row] replaceObjectAtIndex:3 withObject: [NSString stringWithFormat:@"%d", totalYesCount]];
	[[self.questionList objectAtIndex:row] replaceObjectAtIndex:4 withObject: [NSString stringWithFormat:@"%d", totalAnswerCount]];
	 
	//Submit answer
	if(![answerString isEqualToString:@"2"] && ![previousAnswer isEqualToString:answerString])
	{
		NSLog(@"Submitting Answer");
		NSString *strAnswersUrl = [NSString stringWithFormat:@"%@?action=submit_answer&udid=%@&question_id=%@&answer=%@",baseUrl, udid, questionId, answerString];
		NSURL* urlAnswers = [NSURL URLWithString:strAnswersUrl];
		
		//Submit answer asynchronously
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlAnswers cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
		[[NSURLConnection alloc] initWithRequest:request delegate:self];
	}
}

#pragma mark -
#pragma mark Table View Data Source Methods

-(void)setSwitchAction:(UITableViewCell *) cell {
	[(UISwitch *)cell.accessoryView addTarget:self action:@selector(answerQuestion:) forControlEvents:UIControlEventValueChanged];
	[super setSwitchAction: cell];  
}

#pragma mark -

@end
