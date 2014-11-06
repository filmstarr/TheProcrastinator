//
//  UICustomSwitch.h
//
//  Created by Hardy Macia on 10/28/09.
//  Copyright 2009 Catamount Software. All rights reserved.
//
//  Code can be freely redistruted and modified as long as the above copyright remains.
//

#import <Foundation/Foundation.h>


@interface UICustomSwitch : UISlider {
	BOOL on;
	BOOL hasValue;
	BOOL enabled;
	UIColor *tintColor;
	UIView *clippingView;
	UILabel *rightLabel;
	UILabel *leftLabel;
	NSDate *touchTime;
	
	// private member
	BOOL m_touchedSelf;
}

@property (nonatomic,getter=isOn) BOOL on;
@property (nonatomic) BOOL enabled;
@property (nonatomic,retain) UIColor *tintColor;
@property (nonatomic,retain) UIView *clippingView;
@property (nonatomic,retain) UILabel *rightLabel;
@property (nonatomic,retain) UILabel *leftLabel;

+ (UICustomSwitch *) switchWithLeftText: (NSString *) tag1 andRight: (NSString *) tag2;

- (void)setOn:(BOOL)on animated:(BOOL)animated;
- (void)setEnabled:(BOOL)enabled;
- (void)scaleSwitch:(CGSize)newSize;

@end
