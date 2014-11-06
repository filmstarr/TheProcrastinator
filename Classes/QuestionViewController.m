    //
//  QuestionViewController.m
//  YesNo
//
//  Created by Ross Huelin on 05/05/2011.
//  Copyright 2011 Ross Huelin. All rights reserved.
//

#import "QuestionViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "LoadingView.h"
#import "QuestionTableViewController.h"
#import "YesNoAppDelegate.h"
#import "UICustomSwitch.h"
#import "PieChart.h"


@implementation QuestionViewController

@synthesize questionDetails, contentView, questionText, row, myQuestion, answerControl, myPie;

#pragma mark UIViewController delegate methods

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	//Round off corners
	questionText.layer.cornerRadius = 10;
	questionText.clipsToBounds = YES;
	
	//Set question text
	[self setQuestionValues];
	
	//Set variables
	loadingViewShowing = NO;
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	baseUrl = [standardUserDefaults objectForKey:@"baseUrl"];
	udid = [standardUserDefaults objectForKey:@"udid"];
	submittingAnswer = NO;
	
    [super viewDidLoad];
}

- (void)dealloc {
	[questionDetails release];
	[contentView release];
	[questionText release];
	[answerControl release];
	[myPie release];
    [super dealloc];
}

- (oneway void)release
{
	//Ensure that we always release on the main thread
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(release) withObject:nil waitUntilDone:NO];
    } else {
        [super release];
    }
}

#pragma mark -
#pragma mark User interface actions

-(void)reload {
	NSLog(@"Reloading question details");
	submittingAnswer = NO;
	[self showLoadingView];
	
	UIApplication *app = [UIApplication sharedApplication];
	backgroundTask = [app beginBackgroundTaskWithExpirationHandler:^{
		dispatch_async(dispatch_get_main_queue(), ^{
			if (backgroundTask != UIBackgroundTaskInvalid) {
				[app endBackgroundTask:backgroundTask];
				backgroundTask = UIBackgroundTaskInvalid;
			}
		});
	}];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
		//Background processing custom code start
		NSString *strUrl = [NSString stringWithFormat:@"%@?action=retrieve_answer&udid=%@&question_id=%@",baseUrl, udid, [self.questionDetails objectAtIndex:0]];
		if (myQuestion) {
			strUrl = [NSString stringWithFormat:@"%@?action=retrieve_question&udid=%@&question_id=%@",baseUrl, udid, [self.questionDetails objectAtIndex:0]];		
		}
		NSURL* url = [NSURL URLWithString:strUrl];
		NSString *question = [[NSString alloc] initWithContentsOfURL:url];
		[self processQuestion: question];
		[self performSelectorOnMainThread:@selector(hideLoadingView) withObject:nil waitUntilDone:NO];
		[question release];
		//Background processing custom code end
		
		dispatch_async(dispatch_get_main_queue(), ^{
			if (backgroundTask != UIBackgroundTaskInvalid)
			{
				[app endBackgroundTask:backgroundTask];
				backgroundTask = UIBackgroundTaskInvalid;
			}
		});
	});
	
	NSLog(@"Question details reloaded");
}

//Show loading view
- (void)showLoadingView {
	if (!loadingViewShowing)
	{
		if (submittingAnswer) {
			loadingView = [LoadingView loadingViewInView:myPie];
		}
		else {
			loadingView = [LoadingView loadingViewInView:contentView];
		}
		loadingViewShowing = YES;
	}
}

//Hide loading view
- (void)hideLoadingView {
	//Hide loading view
	if (loadingViewShowing)
	{
		[loadingView performSelector:@selector(removeView) withObject:nil afterDelay:0];
		loadingViewShowing = NO;
	}
}

- (void)processQuestion: (NSString *) question {
	if (![question isEqualToString:@"0"] && [question length] >= 2)
	{
		NSMutableArray *tempQuestionDetails = [[NSMutableArray alloc] initWithArray:[question componentsSeparatedByString:@"\t"]];
		if ([tempQuestionDetails count] == 5)
		{
			//Replace question in Asking/Answering view
			YesNoAppDelegate *mainDelegate = (YesNoAppDelegate *)[[UIApplication sharedApplication] delegate];
			QuestionTableViewController *qtvc = [[mainDelegate.navigationController viewControllers] objectAtIndex:1];
			if ([qtvc.questionList count] > self.row) {
				[qtvc.questionList replaceObjectAtIndex:self.row withObject:tempQuestionDetails];
			}
			self.questionDetails = tempQuestionDetails;
			[self performSelectorOnMainThread:@selector(setQuestionValues) withObject:nil waitUntilDone:NO];
		}
		else {
			if (submittingAnswer) {
				[self performSelectorOnMainThread:@selector(alert:) withObject:@"Sorry, answer submission failed. Please try again." waitUntilDone:NO];
			}
			else {
				[self performSelectorOnMainThread:@selector(alert:) withObject:@"Sorry, we could not reload the question. Please try again." waitUntilDone:NO];
			}
		}

		[tempQuestionDetails release];
	}
	else {
		if (submittingAnswer) {
			[self performSelectorOnMainThread:@selector(alert:) withObject:@"Sorry, answer submission failed. Please try again." waitUntilDone:NO];
		}
		else {
			[self performSelectorOnMainThread:@selector(alert:) withObject:@"Sorry, we could not reload the question. Please try again." waitUntilDone:NO];
		}
	}	
}

- (void)alert:(NSString *) alertString
{
	//show the user an error message
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"The Procrastinator" message:alertString delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
	[alertView show]; 
	[alertView release];
}

- (void)setQuestionValues
{
	loaded = NO;
	//Set question text
	questionText.text = [questionDetails objectAtIndex:1];
	
	if ([answerControl numberOfSegments] == 2) {
		//Enable or disable answer segments
		if (myQuestion) {
			[answerControl setEnabled:NO forSegmentAtIndex:0];
			[answerControl setEnabled:NO forSegmentAtIndex:1];
			answerControl.alpha = 0.9;
		}
		else{
			[answerControl setEnabled:YES forSegmentAtIndex:0];
			[answerControl setEnabled:YES forSegmentAtIndex:1];
		}

		//Set the answer
		NSString *answer = [questionDetails objectAtIndex:2];
		if([answer isEqualToString:@"0"]) {
			[answerControl setSelectedSegmentIndex:1];
		}
		else if ([answer isEqualToString:@"1"]) {
			[answerControl setSelectedSegmentIndex:0];
		}
		else {
			[answerControl setSelectedSegmentIndex:-1];
		}
	}
	
	//Set pie chart values
	NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
	NSString *totalYesCountStr = [[questionDetails objectAtIndex:3] copy];
	NSString *totalAnswerCountStr = [[questionDetails objectAtIndex:4] copy];

	if ([f numberFromString: totalYesCountStr] && [f numberFromString: totalAnswerCountStr])
	{
		myPie.yesCount = [totalYesCountStr intValue];
		myPie.totalCount = [totalAnswerCountStr intValue];
	}
	[f release];
	[myPie setNeedsDisplay];
	
	loaded = YES;
}

- (IBAction)answerQuestion:(id) sender
{
	if(loaded) {
		//Get values
		NSString *questionId = [questionDetails objectAtIndex:0];
		NSString *answerString = @"2";
		
		//Generate our answer string
		if (answerControl.selectedSegmentIndex == 0) {
			answerString = @"1";
		}
		else {
			answerString = @"0";
		}
		
		NSString *previousAnswer = [questionDetails objectAtIndex:2];
		
		//Submit answer
		if(![answerString isEqualToString:@"2"] && ![previousAnswer isEqualToString:answerString])
		{
			NSLog(@"Submitting Answer");
			NSString *strAnswersUrl = [NSString stringWithFormat:@"%@?action=submit_answer_retrieve_answer&udid=%@&question_id=%@&answer=%@",baseUrl, udid, questionId, answerString];
			NSURL* urlAnswers = [NSURL URLWithString:strAnswersUrl];

			//Submit answer asynchronously
			submittingAnswer = YES;
			[self showLoadingView];
			NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlAnswers cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
			[[NSURLConnection alloc] initWithRequest:request delegate:self];
		}
	}
}

#pragma mark -
#pragma mark Asynchronous request actions

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    questionData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [questionData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"Error: %@", error);
    [questionData release];
    [connection release];
	[self submissionFailed];
	[self performSelectorOnMainThread:@selector(hideLoadingView) withObject:nil waitUntilDone:NO];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{	
	//Get question details after answer submission
	NSString *question = [[[NSString alloc] initWithData:questionData encoding: NSASCIIStringEncoding] autorelease];

	//Check for failure
	if (![question isEqualToString: @"0"] && [question length] >= 2) {
		[self processQuestion: question];
	}
	else {
		[self submissionFailed];
		[self reload];
	}
	[self performSelectorOnMainThread:@selector(hideLoadingView) withObject:nil waitUntilDone:NO];
    [questionData release];
}

- (void)submissionFailed
{
	[self alert: @"Sorry, answer submission failed. Reloading answers."];
	[self reload];
}

#pragma mark -

@end
