//
//  PieChart.m
//  YesNo
//
//  Created by Ross Huelin on 28/05/2011.
//  Copyright 2011 Ross Huelin. All rights reserved.
//

#import "PieChart.h"

static inline float radians(double degrees) { return degrees * M_PI / 180; }

@implementation PieChart

@synthesize yesCount, totalCount, yesCountLabel, noCountLabel, yesLabel, noLabel;

- (void)drawRect:(CGRect)rect {
	NSLog(@"Drawing pie chart");
	
    // Get the graphics context and clear it
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextClearRect(ctx, rect);
	
	//Definel some parameters
	CGFloat offset = 4.0;
	CGFloat padding = 10.0;
	CGFloat lineWidth = 1.0;
	UIColor *yesColour = [UIColor greenColor];
	UIColor *noColour = [UIColor redColor];
	UIColor *borderColour = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
											  
	//Set up chart variables
	offset += lineWidth;
	CGRect parentViewBounds = self.bounds;
	CGFloat y = CGRectGetHeight(parentViewBounds) * 0.5;
	CGFloat x = CGRectGetWidth(parentViewBounds) - y - offset - lineWidth;
	CGFloat radius = y - padding;
	CGContextSetStrokeColor(ctx, CGColorGetComponents([borderColour CGColor]));
	CGContextSetLineWidth(ctx, lineWidth);
	
	//Set percentage value
	double yesPercentage = 0.5;
	if (totalCount != 0.0 && yesCount <= totalCount)
	{
		yesPercentage = (double)yesCount / (double)totalCount;
	}
	double noPercentage = 1 - yesPercentage;
		
	//Set no segment angles
	double noSegmentStart = -180.0;
	double noSegmentFinish = 180.0;
	
	if (noPercentage != 0.0)
	{
		noSegmentStart = - (noPercentage * 360.0 / 2);
		noSegmentFinish = noPercentage * 360.0 / 2;
	}
		
	if (noPercentage < 1.0) {
		//Add yes border segment
		CGContextSetFillColor(ctx, CGColorGetComponents([borderColour CGColor]));
		CGContextMoveToPoint(ctx, x, y);
		CGContextAddArc(ctx, x, y, radius + lineWidth, radians(noSegmentFinish), radians(noSegmentStart), 0);
		CGContextClosePath(ctx);
		CGContextFillPath(ctx);
	
		//Add yes segment
		CGContextSetFillColor(ctx, CGColorGetComponents([yesColour CGColor]));
		CGContextMoveToPoint(ctx, x, y);
		CGContextAddArc(ctx, x, y, radius, radians(noSegmentFinish), radians(noSegmentStart), 0);
		CGContextClosePath(ctx);
		CGContextFillPath(ctx);
	
		//Add yes border lines
		if (noPercentage > 0.0)
		{
			CGContextMoveToPoint(ctx, x, y);
			CGContextAddLineToPoint(ctx, x + (cos(radians(noSegmentStart)) * (radius + lineWidth)), y + (sin(radians(noSegmentStart)) * (radius + lineWidth)));
			CGContextStrokePath(ctx);
			CGContextMoveToPoint(ctx, x, y);
			CGContextAddLineToPoint(ctx, x + (cos(radians(noSegmentStart)) * (radius + lineWidth)), y - (sin(radians(noSegmentStart)) * (radius + lineWidth)));
			CGContextStrokePath(ctx);
		}
	}

	if (noPercentage > 0.0)
	{
		//Add no border segment
		CGContextSetFillColor(ctx, CGColorGetComponents([borderColour CGColor]));
		CGContextMoveToPoint(ctx, x + offset, y);
		CGContextAddArc(ctx, x + offset, y, radius + lineWidth, radians(noSegmentStart), radians(noSegmentFinish), 0);
		CGContextClosePath(ctx);
		CGContextFillPath(ctx);
						
		//Add no segment
		CGContextSetFillColor(ctx, CGColorGetComponents([noColour CGColor]));
		CGContextMoveToPoint(ctx, x + offset, y);
		CGContextAddArc(ctx, x + offset, y, radius, radians(noSegmentStart), radians(noSegmentFinish), 0);
		CGContextClosePath(ctx);
		CGContextFillPath(ctx);
		
		//Add no border lines
		if (noPercentage < 1.0)
		{
			CGContextMoveToPoint(ctx, x + offset, y);
			CGContextAddLineToPoint(ctx, x + offset + (cos(radians(noSegmentStart)) * (radius + lineWidth)), y + (sin(radians(noSegmentStart)) * (radius + lineWidth)));
			CGContextStrokePath(ctx);
			CGContextMoveToPoint(ctx, x + offset, y);
			CGContextAddLineToPoint(ctx, x + offset + (cos(radians(noSegmentStart)) * (radius + lineWidth)), y - (sin(radians(noSegmentStart)) * (radius + lineWidth)));
			CGContextStrokePath(ctx);
		}
	}
	
	//Set label text and colour
	yesCountLabel.text = [NSString stringWithFormat:@"(%d)", yesCount];
	noCountLabel.text = [NSString stringWithFormat:@"(%d)", totalCount - yesCount];
	yesLabel.text = [NSString stringWithFormat:@"Yes - %.0lf%%", yesPercentage * 100];
	noLabel.text = [NSString stringWithFormat:@"No - %.0lf%%", noPercentage * 100];
	
	yesCountLabel.textColor = yesColour;
	noCountLabel.textColor = noColour;
	yesLabel.textColor = yesColour;
	noLabel.textColor = noColour;
	
	//Add gradient overlay
    CGGradientRef glossGradient;
    CGColorSpaceRef rgbColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 0.098, 0.098, 0.098, 0.0,  // Start color
							  0.098, 0.098, 0.098, 0.7 }; // End color
	
    rgbColorspace = CGColorSpaceCreateDeviceRGB();
    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
	
    CGRect currentBounds = self.bounds;
    CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
    CGPoint bottomCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetHeight(parentViewBounds));
    CGContextDrawLinearGradient(ctx, glossGradient, topCenter, bottomCenter, 0);
	
    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace);
}

- (void)dealloc
{
    [yesCountLabel release];
    [noCountLabel release];
    [yesLabel release];
	[noLabel release];
	
    [super dealloc];
}

@end