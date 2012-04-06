//
//  CustomAlertView.h
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

#import <UIKit/UIKit.h>


@interface CustomAlertView : UIView {
	UILabel *titleLabel;
	id target;
	SEL sel;
	id userInfo;
}

@property (nonatomic, retain) UILabel *titleLabel;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title;
- (void)showInPareantView:(UIView *)parentView center:(CGPoint)_center;

- (void)setTarget:(id)_target selector:(SEL)_sel usrInfo:(id)_userInfo;

@end
