//
//  QuestionScrollerViewController.h
//  YesNo
//
//  Created by Ross Huelin on 19/05/2011.
//  Copyright 2011 Ross Huelin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionTableViewController.h"


@interface QuestionScrollerViewController : UIViewController <UIScrollViewDelegate>
{   
    UIScrollView *scrollView;
    NSMutableArray *viewControllers;
	NSMutableArray *questionList;
	NSInteger selectedRow;
	BOOL loading;
	NSInteger batchSize;
	NSInteger loadedAtRow;
	NSMutableData *questionData;
	NSString *baseUrl;
	NSString *udid;
	BOOL myQuestions;
	IBOutlet UIButton *removeButton;
}

@property(nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property(nonatomic, retain) NSMutableArray *viewControllers;
@property(nonatomic, retain) NSMutableArray *questionList;
@property(nonatomic, retain) UIButton *removeButton;
@property(nonatomic, assign) NSInteger selectedRow;
@property(nonatomic, assign) BOOL myQuestions;

- (void)layoutAndLoadCurrentPage;
- (void)loadScrollViewWithPage:(int)page;
- (void)scrollViewDidScroll:(UIScrollView *)sender;
- (IBAction)removeQuestion:(id)sender;
- (void)validateViewControllers;
- (void)unLoadScrollViewWithPage:(int)page withAnimation:(BOOL)animated;
- (void)loadMoreQuestions:(QuestionTableViewController*)qtvc;
- (void)requestFailed;
- (void)alert:(NSString *) alertString;

@end