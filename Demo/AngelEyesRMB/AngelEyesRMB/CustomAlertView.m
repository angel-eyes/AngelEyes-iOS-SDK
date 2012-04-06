//
//  CustomAlertView.m
//
//  Copyright 2012 www.angeleyes.it. All rights reserved
//
//  Created by koupoo
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "CustomAlertView.h"
#import <QuartzCore/QuartzCore.h>


@implementation CustomAlertView
@synthesize titleLabel;


- (id)initWithFrame:(CGRect)frame title:(NSString *)title{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.8];		
		titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                               frame.size.height * 3 / 7,
                                                               frame.size.width, 
                                                               frame.size.height / 7)];
        titleLabel.textAlignment = UITextAlignmentCenter;
		UIFont *textFont = [UIFont systemFontOfSize:12];
		
		titleLabel.font = textFont;
		titleLabel.textColor = [UIColor whiteColor];
		[titleLabel setTextAlignment:UITextAlignmentCenter];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[titleLabel setText:title];
		
		[self addSubview:titleLabel];
		
		self.layer.cornerRadius = frame.size.height / 12;;
    }
    return self;
}

- (void)showInPareantView:(UIView *)parentView center:(CGPoint)_center{
	[self retain];
	self.center = _center;
	self.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.8];
	[parentView addSubview:self];
	
    [UIView animateWithDuration:1.5 
                          delay:0.8 
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
						 self.alpha = 0;
					 }
                     completion:^(BOOL finished){
						 [self removeFromSuperview];
						 
						 if (target != nil) {
							 [target performSelector:sel withObject:userInfo];
						 }
						 
						 [self release];
					 }];
}

- (void)setTarget:(id)_target selector:(SEL)_sel usrInfo:(id)_userInfo{
	if (_target == nil) {
		return;
	}
	
	[target retain];
	target = _target;
	
	if (_userInfo != nil) {
		[_userInfo retain];
		userInfo = _userInfo;
	}
	
	sel = _sel;
}


- (void)dealloc {
	[titleLabel release];
	[target release];
	[userInfo release];
    [super dealloc];
}


@end
