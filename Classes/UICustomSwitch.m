//
//  UICustomSwitch.m
//
//  Created by Hardy Macia on 10/28/09.
//  Copyright 2009 Catamount Software. All rights reserved.
//
//  Code can be freely redistruted and modified as long as the above copyright remains.
//

#import "UICustomSwitch.h"


@implementation UICustomSwitch

@synthesize on, enabled;
@synthesize tintColor, clippingView, leftLabel, rightLabel;

+(UICustomSwitch *)switchWithLeftText:(NSString *)leftText andRight:(NSString *)rightText
{
	UICustomSwitch *switchView = [[UICustomSwitch alloc] initWithFrame:CGRectZero];
	
	switchView.leftLabel.text = leftText;
	switchView.rightLabel.text = rightText;
	
	return [switchView autorelease];
}

-(id)initWithFrame:(CGRect)rect
{
	if ((self=[super initWithFrame:CGRectMake(rect.origin.x,rect.origin.y,64,27)]))
	{
		//		self.clipsToBounds = YES;
		
		[self awakeFromNib];
	}
	return self;
}

-(void)awakeFromNib
{
	[super awakeFromNib];
	
	self.backgroundColor = [UIColor clearColor];

	[self setThumbImage:[UIImage imageNamed:@"switch-button.png"] forState:UIControlStateNormal];
	[self setMinimumTrackImage:[UIImage imageNamed:@"switch-left.png"] forState:UIControlStateNormal];
	[self setMaximumTrackImage:[UIImage imageNamed:@"switch-right.png"] forState:UIControlStateNormal];
	
	self.minimumValue = 0;
	self.maximumValue = 1;
	self.continuous = NO;
	
	hasValue = NO;
	self.value = 0.5;
	enabled = YES;
		
	self.clippingView = [[UIView alloc] initWithFrame:CGRectMake(3,2,58,23)];
	self.clippingView.clipsToBounds = YES;
	self.clippingView.userInteractionEnabled = NO;
	self.clippingView.backgroundColor = [UIColor clearColor];
	[self addSubview:self.clippingView];
	[self.clippingView release];
	
	NSString *leftLabelText = NSLocalizedString(@"YES","Custom UISwitch YES label. If localized to empty string then I/O will be used");
	if ([leftLabelText length] == 0)	
	{
		leftLabelText = @"l";		// use helvetica lowercase L to be a 1. 
	}
	
	self.leftLabel = [[UILabel alloc] init];
	self.leftLabel.frame = CGRectMake(0, 0, 41, 23);
	self.leftLabel.text = leftLabelText;
	self.leftLabel.textAlignment = UITextAlignmentCenter;
	self.leftLabel.font = [UIFont boldSystemFontOfSize:11];
	self.leftLabel.textColor = [UIColor whiteColor];
	self.leftLabel.backgroundColor = [UIColor clearColor];
	//		self.leftLabel.shadowColor = [UIColor redColor];
	//		self.leftLabel.shadowOffset = CGSizeMake(0,0);
	[self.clippingView addSubview:self.leftLabel];
	[self.leftLabel release];
	
	
	NSString *rightLabelText = NSLocalizedString(@"NO","Custom UISwitch NO label. If localized to empty string then I/O will be used");
	if ([rightLabelText length] == 0)	
	{
		rightLabelText = @"O";	// use helvetica uppercase o to be a 0. 
	}
	
	self.rightLabel = [[UILabel alloc] init];
	self.rightLabel.frame = CGRectMake(64, 0, 41, 23);
	self.rightLabel.text = rightLabelText;
	self.rightLabel.textAlignment = UITextAlignmentCenter;
	self.rightLabel.font = [UIFont boldSystemFontOfSize:11];
	self.rightLabel.textColor = [UIColor grayColor];
	self.rightLabel.backgroundColor = [UIColor clearColor];
	//		self.rightLabel.shadowColor = [UIColor redColor];
	//		self.rightLabel.shadowOffset = CGSizeMake(0,0);
	[self.clippingView addSubview:self.rightLabel];
	[self.rightLabel release];
}

-(void)layoutSubviews
{
	[super layoutSubviews];
	
	//	NSLog(@"leftLabel=%@",NSStringFromCGRect(self.leftLabel.frame));
	//NSLog([NSString stringWithFormat:@"%lf", self.value]);

	// move the labels to the front
	[self.clippingView removeFromSuperview];
	[self addSubview:self.clippingView];
	
	CGFloat thumbWidth = self.currentThumbImage.size.width;
	CGFloat switchWidth = self.bounds.size.width;
	CGFloat labelWidth = switchWidth - thumbWidth;
	CGFloat inset = self.clippingView.frame.origin.x;
	
	//	NSInteger xPos = self.value * (self.bounds.size.width - thumbWidth) - (self.leftLabel.frame.size.width - thumbWidth/2); 
	NSInteger xPos = self.value * labelWidth - labelWidth - inset;
	self.leftLabel.frame = CGRectMake(xPos + 2, 0, labelWidth, 23);
	
	//	xPos = self.value * (self.bounds.size.width - thumbWidth) + (self.rightLabel.frame.size.width - thumbWidth/2); 
	xPos = switchWidth + (self.value * labelWidth - labelWidth) - inset; 
	self.rightLabel.frame = CGRectMake(xPos - 2, 0, labelWidth, 23);
	
	//	NSLog(@"value=%f    xPos=%i",self.value,xPos);
	//	NSLog(@"thumbWidth=%f    self.bounds.size.width=%f",thumbWidth,self.bounds.size.width);
}

- (void)scaleSwitch:(CGSize)newSize 
{
	self.transform = CGAffineTransformMakeScale(newSize.width,newSize.height);
}

- (void)setOn:(BOOL)turnOn animated:(BOOL)animated;
{
	hasValue = YES;

	on = turnOn;
	
	if (animated)
	{
		[UIView	beginAnimations:@"UICustomSwitch" context:nil];
		[UIView setAnimationDuration:0.2];
	}
	
	if (on)
	{
		self.value = 1.0;
	}
	else 
	{
		self.value = 0.0;
	}
	
	if (animated)
	{
		[UIView	commitAnimations];	
	}
}

- (void)setOn:(BOOL)turnOn
{
	hasValue = YES;
	[self setOn:turnOn animated:NO];
}

- (void)setEnabled:(BOOL)enable
{
	enabled = enable;
	
	if (!enable) {
		for (UIView *vw in [self subviews]) {
			vw.alpha = 0.5;
		}
	}
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	if (!enabled) return;
//	NSLog(@"preendTrackingWithtouch");

	[super endTrackingWithTouch:touch withEvent:event];
//	NSLog(@"postendTrackingWithtouch");
	m_touchedSelf = YES;
	
	[self setOn:on animated:YES];
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	if (!enabled) return;
	[super touchesBegan:touches withEvent:event];
//	NSLog(@"touchesBegan");
	m_touchedSelf = NO;
	//Don't need to just toggle it anymore
	//on = !on;

	//Store touch began time
	touchTime = [[NSDate alloc] init];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{	
	if (!enabled) return;
	//NSLog([NSString stringWithFormat:@"%lf",[[[NSDate alloc] init] timeIntervalSinceDate:touchTime]]);
		
	//Set the value that has been selected
	if ([[[NSDate alloc] init] timeIntervalSinceDate:touchTime] < 0.05 && hasValue) {
		//User tapped so toggle switch
		on = !on;
	}
	else {		
		if (self.value >= 0.5) {
			//If we're greater or equal to half way then ON
			on = YES;
		}
		else {
			//If we're less than half way then OFF
			on = NO;
		}
	}
	
	[super touchesEnded:touches withEvent:event];
	//	NSLog(@"touchesEnded");

	if (!m_touchedSelf)
	{
		[self setOn:on animated:YES];
		[self sendActionsForControlEvents:UIControlEventValueChanged];
	}
}

-(void)dealloc
{
	[tintColor release];
	[clippingView release];
	[rightLabel release];
	[leftLabel release];
	
	[super dealloc];
}

@end
