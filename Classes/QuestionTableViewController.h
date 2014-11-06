//
//  QuestionTableViewController.h
//  YesNo
//
//  Created by Ross Huelin on 25/05/2011.
//  Copyright 2011 Ross Huelin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingView.h"

@class QuestionViewController;

@interface QuestionTableViewController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
	NSString *action;
	NSMutableArray *questionList;
	IBOutlet UITableView *questionTable;
	NSString *baseUrl;
	NSString *udid;
	NSInteger batchSize;
	LoadingView *loadingView;
	BOOL loadingViewShowing;
	BOOL answerSitchEnabled;
	IBOutlet UIView *tableWrapperView;
	NSInteger lastQuestionId;
	UIBackgroundTaskIdentifier loadTask;
	BOOL reloading;
	NSInteger firstUserQuestion;
	BOOL questionLoadingComplete;	
	NSInteger selectedRow;
	QuestionViewController *questionViewController;
	BOOL myQuestions;
}

@property(nonatomic, retain) NSMutableArray *questionList;
@property(nonatomic, retain) UITableView *questionTable;
@property(nonatomic, retain) UIView *tableWrapperView;
@property(nonatomic, retain) IBOutlet QuestionViewController *questionViewController;
@property(nonatomic, assign) NSInteger selectedRow;
@property(nonatomic, assign) NSInteger lastQuestionId;
@property(nonatomic, assign) BOOL questionLoadingComplete;

- (void)setSwitchAction:(UITableViewCell *) cell;
- (void)resetView;
- (void)operationFailed;
- (void)showLoadingView;
- (void)hideLoadingView;
- (void)loadQuestions;
- (void)loadQuestions:(BOOL)quiet;
- (void)setTitle;
- (void)performLoad:(NSURL *)urlQuestions;
- (void)processQuestions:(NSString *) questions;
- (void)alert:(NSString *) alertString;
- (BOOL)loadMoreQuestions:(NSInteger) currentRow;

@end
