    //
//  QuestionScrollerViewController.m
//  YesNo
//
//  Created by Ross Huelin on 19/05/2011.
//  Copyright 2011 Ross Huelin. All rights reserved.
//

#import "QuestionScrollerViewController.h"
#import "QuestionViewController.h"
#import "QuestionTableViewController.h"


@implementation QuestionScrollerViewController

@synthesize scrollView, viewControllers, questionList, removeButton, selectedRow, myQuestions;

#pragma mark UIViewController delegate methods

- (void)viewDidLoad
{
	//Get parameters
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	batchSize = [standardUserDefaults integerForKey:@"batchSize"];
	baseUrl = [standardUserDefaults objectForKey:@"baseUrl"];
	udid = [standardUserDefaults objectForKey:@"udid"];

    // view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < [self.questionList count]; i++)
    {
		[controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    [controllers release];
    
    // a page is the width of the scroll view
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * [self.questionList count], scrollView.frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
        
	//Layout and load the current page
	[self layoutAndLoadCurrentPage];
	
	//Set title
	[self setTitle:[NSString stringWithFormat:@"Question %d (%d loaded)", selectedRow + 1, [self.questionList count]]];
	
	//Set button text
	if (myQuestions) {
		[removeButton setTitle:@"Delete Question" forState:UIControlStateNormal];
	}
	else {
		[removeButton setTitle:@"Remove Question" forState:UIControlStateNormal];
	}
	removeButton.titleLabel.textAlignment = UITextAlignmentCenter;
	
	//Add reload button
	UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload:)];          
	self.navigationItem.rightBarButtonItem = reloadButton;
	[reloadButton release];
	
	//Initialise values
	loadedAtRow = 0;
}

- (void)dealloc
{
    [viewControllers release];
    [scrollView release];
    [questionList release];
	[removeButton release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark User interface actions

- (void)setTitle:(NSString *) titleText {
	UILabel* tlabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, 190, 45)];
	tlabel.text = titleText;
    tlabel.textColor = [UIColor whiteColor];
    tlabel.backgroundColor = [UIColor clearColor];
    tlabel.adjustsFontSizeToFitWidth = YES;
	tlabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = tlabel;
}

- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0)
        return;
    if (page >= [self.questionList count])
        return;
    
    // replace the placeholder if necessary
    QuestionViewController *controller = [viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
        controller = [[QuestionViewController alloc] initWithNibName:@"Question" bundle:nil];

		//Set question view values
		controller.questionDetails = [self.questionList objectAtIndex:page];
		controller.row = page;
		controller.myQuestion = myQuestions;
        
		[viewControllers replaceObjectAtIndex:page withObject:controller];
        [controller release];
    }
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
		[scrollView addSubview:controller.view];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{	
	//Check view controllers
	[self validateViewControllers];
	
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    selectedRow = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:selectedRow - 1];
    [self loadScrollViewWithPage:selectedRow];
    [self loadScrollViewWithPage:selectedRow + 1];
	
	//Unload views two out
    [self unLoadScrollViewWithPage:selectedRow - 2 withAnimation:NO];
    [self unLoadScrollViewWithPage:selectedRow + 2 withAnimation:NO];	
	
	//Set title
	UILabel* tlabel = (UILabel*)self.navigationItem.titleView;
	tlabel.text = [NSString stringWithFormat:@"Question %d (%d loaded)", selectedRow + 1, [self.questionList count]];

	//Set the selected row in the parent view controller
	QuestionTableViewController *qtvc = [[self.navigationController viewControllers] objectAtIndex:1];
	qtvc.selectedRow = self.selectedRow;
	
	//Do we need to load some more questions
	[self loadMoreQuestions:qtvc];
}

- (void)loadMoreQuestions:(QuestionTableViewController*)qtvc
{
	if (self.selectedRow >= loadedAtRow + batchSize - 1)
	{
		if ([qtvc loadMoreQuestions:self.selectedRow]) {
			NSLog(@"Loaded more results in parent view controller");
			loadedAtRow = self.selectedRow;
		}
	}	
}

- (void)unLoadScrollViewWithPage:(int)page withAnimation:(BOOL)animated
{
    if (page < 0)
        return;
    if (page >= [self.questionList count])
        return;

	QuestionViewController *qvc = [self.viewControllers objectAtIndex:page];
    if ((NSNull *)qvc != [NSNull null])
    {
		if (animated)
		{
			[UIView beginAnimations:@"curldown" context:nil];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDuration:.5];
			[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:qvc.view.superview cache:YES];
			[qvc.view removeFromSuperview];
			[UIView commitAnimations];
		}
		else {
			[qvc.view removeFromSuperview];
		}

		[self.viewControllers replaceObjectAtIndex:page withObject:[NSNull null]];
    }
}

- (void)layoutAndLoadCurrentPage
{
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:selectedRow - 1];
    [self loadScrollViewWithPage:selectedRow];
    [self loadScrollViewWithPage:selectedRow + 1];
    
	// update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * selectedRow;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:NO];
}

- (IBAction)reload:(id) sender {
	QuestionViewController *qvc = [self.viewControllers objectAtIndex:selectedRow];
	[qvc reload];
}

- (IBAction)removeQuestion:(id) sender {
	//Confirmation dialog	
	UIAlertView *alert = [[UIAlertView alloc] init];
	[alert setTitle:@"The Procrastinator"];
	if (myQuestions) {
		[alert setMessage:@"Are you sure you want to delete this question (this cannot be undone)?"];
	}
	else {
		[alert setMessage:@"Are you sure you want to remove this question (this cannot be undone)?"];
	}	
	[alert setDelegate:self];
	[alert addButtonWithTitle:@"Yes"];
	[alert addButtonWithTitle:@"No"];
	[alert show];
	[alert release];
}

//Removing or deleting a question
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)
	{
		NSLog(@"Removing Question");
		//Remove from server asynchronously
		NSString *questionId = [[self.questionList objectAtIndex:selectedRow] objectAtIndex:0];
		NSString *strUrl = [NSString stringWithFormat:@"%@?action=hide_answer&udid=%@&question_id=%@",baseUrl, udid, questionId];
		if (myQuestions) {
			strUrl = [NSString stringWithFormat:@"%@?action=delete_question&udid=%@&question_id=%@",baseUrl, udid, questionId];
		}
		
		NSURL *url = [NSURL URLWithString:strUrl];
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
		[[NSURLConnection alloc] initWithRequest:request delegate:self];
		
		//Check view controllers
		[self validateViewControllers];
		
		//Unload
		[self.viewControllers removeObjectAtIndex:selectedRow];
		[self.questionList removeObjectAtIndex:selectedRow];
		scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * [self.questionList count], scrollView.frame.size.height);
		[self unLoadScrollViewWithPage:selectedRow withAnimation:YES];
		
		//Reload
		[self setTitle:[NSString stringWithFormat:@"Question %d (%d loaded)", selectedRow + 1, [self.questionList count]]];
		[self loadScrollViewWithPage:selectedRow - 1];
		[self loadScrollViewWithPage:selectedRow];
		[self loadScrollViewWithPage:selectedRow + 1];
		
		//If there are no views left then pop
		QuestionTableViewController *qtvc = [[self.navigationController viewControllers] objectAtIndex:1];
		if ([self.questionList count] == 0)
		{
			NSLog(@"No views left returning to parent");
			[qtvc.questionTable reloadData];
			[self.navigationController popViewControllerAnimated: YES];
		}

		//Do we need to load some more questions
		loadedAtRow -= 1;
		[self loadMoreQuestions:qtvc];

	}
}

- (void)validateViewControllers
{
	//Add any new controllers which have been loaded
	if([self.viewControllers count] != [self.questionList count])
	{
		for (unsigned i = [self.viewControllers count]; i < [self.questionList count]; i++)
		{
			[self.viewControllers addObject:[NSNull null]];
		}
		scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * [self.questionList count], scrollView.frame.size.height);
	}	
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
	[self requestFailed];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{	
	//Get a result of request
	NSString *result = [[[NSString alloc] initWithData:questionData encoding: NSASCIIStringEncoding] autorelease];
	if ([result isEqual: @"0"]) {
		[self requestFailed];
	}
    [questionData release];
}

- (void)requestFailed
{
	if (myQuestions) {
		[self alert: @"Sorry, question deletion failed. Please try again later."];
	}
	else {
		[self alert: @"Sorry, question removal failed. Please try again later."];
	}
}

- (void)alert:(NSString *) alertString {
	//show the user an error message
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"The Procrastinator" message:alertString delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
	[alertView show];  
	[alertView release];
}

#pragma mark -

@end

