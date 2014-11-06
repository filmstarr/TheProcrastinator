    //
//  QuestionTableViewController.m
//  YesNo
//
//  Created by Ross Huelin on 25/05/2011.
//  Copyright 2011 Ross Huelin. All rights reserved.
//

#import "QuestionTableViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "LoadingView.h"
#import "UICustomSwitch.h"
#import "QuestionScrollerViewController.h"

@implementation QuestionTableViewController

@synthesize questionList, questionTable, tableWrapperView, questionViewController, selectedRow, lastQuestionId, questionLoadingComplete;

#pragma mark UIViewController delegate methods

- (void)viewDidLoad {
	//Round off corners
	tableWrapperView.layer.cornerRadius = 10;
	tableWrapperView.clipsToBounds = YES;
	
	//Get parameters
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	baseUrl = [standardUserDefaults objectForKey:@"baseUrl"];
	udid = [standardUserDefaults objectForKey:@"udid"];
	batchSize = [standardUserDefaults integerForKey:@"batchSize"];
	
	//Initialise variables
	questionList = [[NSMutableArray alloc] initWithObjects:nil];
	loadingViewShowing = NO;
	lastQuestionId = -1;
	firstUserQuestion = -1;
	questionLoadingComplete = NO;
	reloading = YES;

	//Load questions
	[self loadQuestions];
	
	//Set title
	[self setTitle];
	
	//Add reload button
	UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload:)];          
	self.navigationItem.rightBarButtonItem = reloadButton;
	[reloadButton release];
	
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {
	if ([self.questionList count] > self.selectedRow && [self.questionList count] != 0)
	{
		[questionTable reloadData];
		NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:self.selectedRow inSection:0];	
		[self.questionTable scrollToRowAtIndexPath:selectedIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
	}
}

- (void)dealloc {
	[questionList release];
	[questionTable release];
	[tableWrapperView release];
	[questionViewController release];
  [super dealloc];
}

#pragma mark -
#pragma mark User interface actions

- (void)setTitle {
	UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 190, 45)];
	tlabel.text=self.navigationItem.title;
	tlabel.textColor=[UIColor whiteColor];
	tlabel.backgroundColor =[UIColor clearColor];
	tlabel.adjustsFontSizeToFitWidth=YES;
	tlabel.textAlignment = UITextAlignmentCenter;
	self.navigationItem.titleView=tlabel;
}

-(IBAction)reload:(id) sender {
	NSLog(@"Reloading");
	reloading = YES;
	questionLoadingComplete = NO;
	self.questionList = [[NSMutableArray alloc] initWithObjects:nil];
	lastQuestionId = -1;
	firstUserQuestion = -1;	
	[self loadQuestions];
}

#pragma mark -
#pragma mark Loading View Methods

//Show loading view
- (void)showLoadingView {
	if (!loadingViewShowing)
	{
		loadingView = [LoadingView loadingViewInView:tableWrapperView];
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

#pragma mark -
#pragma mark Question Loading

- (BOOL)loadMoreQuestions:(NSInteger) currentRow
{
	NSInteger answerCount = [self.questionList count];
	if ((currentRow == answerCount || currentRow == answerCount - batchSize - 1) && !questionLoadingComplete && answerCount != 0)
	{
		NSLog(@"Loading more results");
		reloading = NO;
		[self loadQuestions: YES];
		return YES;
	}
	else {
		return NO;
	}
}

- (void)loadQuestions
{
	[self loadQuestions: NO];
}

- (void)loadQuestions:(BOOL)quiet
{
	NSLog(@"Loading questions");
		
	//Load a users questions
	NSString *strQuestionsUrl = [NSString stringWithFormat:@"%@?action=%@&udid=%@",baseUrl, action, udid];
	
	if (lastQuestionId != -1) {
		strQuestionsUrl = [NSString stringWithFormat:@"%@&batch_size=%d&seed=%d",strQuestionsUrl, batchSize, lastQuestionId];
	}
	else {
		//Initially load a double batch
		strQuestionsUrl = [NSString stringWithFormat:@"%@&batch_size=%d",strQuestionsUrl, batchSize*2];		
	}
	
	NSURL* urlQuestions = [NSURL URLWithString:strQuestionsUrl];
	
	//Show loading view as long as we're not being quiet
	if (!quiet) {
		[self showLoadingView];
	}
	
	[self performLoad:urlQuestions];
}

- (void)performLoad:(NSURL *)urlQuestions
{
	UIApplication *app = [UIApplication sharedApplication];
	loadTask = [app beginBackgroundTaskWithExpirationHandler:^{
		dispatch_async(dispatch_get_main_queue(), ^{
			if (loadTask != UIBackgroundTaskInvalid) {
				[app endBackgroundTask:loadTask];
				loadTask = UIBackgroundTaskInvalid;
			}
		});
	}];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
  
		//Background processing custom code start
		BOOL reloadingBefore = reloading;

		//Get a string of the users questions	
		NSString *questions = [[NSString alloc] initWithContentsOfURL:urlQuestions];
				
		//If the request is still current then process results
		if(reloadingBefore == reloading) {
			//Process
			[self processQuestions: questions];
			
			//Hide loading view
			[self performSelectorOnMainThread:@selector(hideLoadingView) withObject:nil waitUntilDone:NO];
		}
		else {
			NSLog(@"Request is no longer current, ignore results.");
		}
		[questions release];
		//Background processing custom code end
		
		dispatch_async(dispatch_get_main_queue(), ^{
			if (loadTask != UIBackgroundTaskInvalid)
			{
				[app endBackgroundTask:loadTask];
				loadTask = UIBackgroundTaskInvalid;
			}
		});
	});
}

- (void) processQuestions: (NSString *) questions
{	
	if (![questions isEqualToString:@"0"] && [questions length] >= 2)
	{			
		@try {
			//Split question rows into an array
			NSArray *initialArray = [[NSArray alloc] initWithArray:[questions componentsSeparatedByString:@"\n"]];					
			
			//Loop through rows and split out component parts
			for (NSString *row in initialArray) {
				
				int firstColon = [row rangeOfString:@":"].location;
				if (firstColon != NSNotFound && [[row substringToIndex:firstColon] isEqualToString:@"first question"]) {
					//Grab the users first question
					NSNumberFormatter *firstQuestionFormatter = [[NSNumberFormatter alloc] init];
					NSString *firstUserQuestionString = [row substringFromIndex:firstColon + 1];
					
					if ([firstQuestionFormatter numberFromString: firstUserQuestionString])
					{
						firstUserQuestion = [firstUserQuestionString intValue];
					}
					[firstQuestionFormatter release];
				}
				else {
					NSMutableArray *rowArray = [[NSMutableArray alloc] initWithArray:[row componentsSeparatedByString:@"\t"]];
					
					//Get the question id
					NSNumberFormatter *questionIdFormatter = [[NSNumberFormatter alloc] init];
					NSString *questionIdString = [rowArray objectAtIndex:0];
					if ([rowArray count] == 5 && [questionIdFormatter numberFromString: questionIdString])	{
						//Only add questions older than the last question id
						if([questionIdString intValue] < lastQuestionId || lastQuestionId == -1) {
							lastQuestionId = [questionIdString intValue];
							[self.questionList addObject:rowArray];
						}
					}
					[questionIdFormatter release];
					[rowArray release];
				}
			}
			
			//Have we finished loading
			if(lastQuestionId <= firstUserQuestion) {
				questionLoadingComplete = YES;	
			}
			
			[initialArray release];
			[self resetView];
		}
		@catch (NSException* ex) {
			[self operationFailed];
		}
	}
	else {
		[self operationFailed];	
	}
}

- (void)resetView
{
	[questionTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void)operationFailed
{
}

- (void)alert:(NSString *) alertString
{
	//show the user an error message
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"The Procrastinator" message:alertString delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
	[alertView show];  
	[alertView release]; 
}

#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (!questionLoadingComplete) {
		return [self.questionList count] + 1;
	}
	else {
		return [self.questionList count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SimpleTableIdentifier] autorelease];
	}
		
	//Some general settings
	[cell.textLabel setTextColor:[UIColor colorWithRed:0.098 green:0.098 blue:0.098 alpha:1.0]];
	
	//Do we need to load some more questions
	NSInteger currentRow = [indexPath row];
	[self loadMoreQuestions:currentRow];
		
	//Show loading in last cell
	NSInteger questionCount = [self.questionList count];
	if (currentRow == questionCount && lastQuestionId > firstUserQuestion)
	{
		cell.accessoryView = nil;
		cell.textLabel.text = NSLocalizedString(@"Loading...", nil);
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
		
		//Add and position activity indicator
		UIActivityIndicatorView *activityIndicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];		
		CGRect rect = activityIndicatorView.frame;
		rect.origin.y = floor(0.5 * (cell.frame.size.height - activityIndicatorView.frame.size.height));
		rect.origin.x = floor((cell.frame.size.width - activityIndicatorView.frame.size.width) - rect.origin.y);
		activityIndicatorView.frame = rect;
		
		[activityIndicatorView startAnimating];
		[cell addSubview: activityIndicatorView];
	}
	else {
		//Tidy up and activity indicator
		for(UIView *subview in [cell subviews]) {
			if([subview isKindOfClass:[UIActivityIndicatorView class]]) {
				[subview removeFromSuperview];
			}
		}		
		cell.textLabel.textAlignment = UITextAlignmentLeft;
	
		@try {
			if (questionCount != 0)
			{
				//Get our question
				cell.textLabel.text = [[questionList objectAtIndex:currentRow] objectAtIndex:1];
	
				//Add a switch
				UICustomSwitch *answerSwitch = [[UICustomSwitch alloc] initWithFrame:CGRectZero];
	
				//Set the answer
				NSString *answer = [[questionList objectAtIndex:currentRow] objectAtIndex:2];
				if([answer isEqualToString:@"0"]) {
					answerSwitch.on = NO;
				}
				else if ([answer isEqualToString:@"1"]) {
					answerSwitch.on = YES;
				}
	
				cell.accessoryView = answerSwitch;
				[answerSwitch release];
	
				//Enable or disable switch
				answerSwitch.enabled = answerSitchEnabled;

				//Set action to be called when switch is changed
        [self setSwitchAction: cell];
			}
		}
		@catch (NSException* ex) {
			NSLog(@"Error loading cells");
		}
	
		//Change the font size and text colour
		[cell.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:11.0]];

	}
	return cell;
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	if ([[[cell textLabel] text] isEqualToString:@"Loading..."]) {
		NSLog(@"Loading more results");
		reloading = NO;
		[self loadQuestions: YES];
	}
	else {
		NSLog(@"Loading Question View");
		QuestionScrollerViewController *qsvc = [[QuestionScrollerViewController alloc] initWithNibName:@"QuestionScroller" bundle:nil];
		qsvc.selectedRow = [indexPath row];
		self.selectedRow = [indexPath row];
		qsvc.questionList = questionList;
		qsvc.myQuestions = myQuestions;
		[self.navigationController pushViewController:qsvc animated:YES];
		[qsvc release];
	}
	
	//Deselect the row again
	[self.questionTable deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)setSwitchAction:(UITableViewCell *) cell {
}

#pragma mark -

@end
