//
//  PieChart.h
//  YesNo
//
//  Created by Ross Huelin on 28/05/2011.
//  Copyright 2011 Ross Huelin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface PieChart : UIView {
	NSInteger yesCount;
	NSInteger totalCount;
	IBOutlet UILabel *yesCountLabel;
	IBOutlet UILabel *noCountLabel;
	IBOutlet UILabel *yesLabel;
	IBOutlet UILabel *noLabel;
}

@property(nonatomic, assign) NSInteger yesCount;
@property(nonatomic, assign) NSInteger totalCount;
@property(nonatomic, retain) UILabel *yesCountLabel;
@property(nonatomic, retain) UILabel *noCountLabel;
@property(nonatomic, retain) UILabel *yesLabel;
@property(nonatomic, retain) UILabel *noLabel;

@end
