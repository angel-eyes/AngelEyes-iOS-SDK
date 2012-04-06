//
//  BlockViewStyle3.m
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

#import "BlockViewStyle3.h"
#import <QuartzCore/QuartzCore.h>


@implementation BlockViewStyle3

@synthesize activityIndicatorView;
@synthesize indicatorLabel;

- (id)initWithFrame:(CGRect)frame indicatorTitle:(NSString *)indicatorTitle animationImages:(NSArray *)images animationDuration:(float)duration{
    if ([images count] < 2) {
        return nil;
    }
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
		activityIndicatorView = [[UIImageView alloc] initWithImage:[images objectAtIndex:0]];
        activityIndicatorView.animationImages = images;
        activityIndicatorView.animationDuration = duration;
		activityIndicatorView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
		
		[self addSubview:activityIndicatorView];
		
		indicatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
																   frame.size.height * 2 / 3,
																   frame.size.width, 
																   frame.size.height / 5)];
		UIFont *textFont = [UIFont systemFontOfSize:12];
		
		indicatorLabel.font = textFont;
		
		[indicatorLabel setTextAlignment:UITextAlignmentCenter];
		[indicatorLabel setBackgroundColor:[UIColor clearColor]];
		[indicatorLabel setText:indicatorTitle];
		
		[self addSubview:indicatorLabel];
        
		self.layer.cornerRadius = frame.size.height / 12;;
    }
    return self;
}


- (void)dealloc {
    [activityIndicatorView stopAnimating];
	[activityIndicatorView release];
	[indicatorLabel release];
    [super dealloc];
}

@end
